import {
  onRequest,
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {
  getFirestore,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";

initializeApp();

const db = getFirestore();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

type EmergencyStatus =
  | "PENDING"
  | "READY_FOR_ESCALATION"
  | "ESCALATING"
  | "CONTACT_REACHED"
  | "ESCALATION_EXHAUSTED"
  | "CANCELLED";

const emergencyStatusTransitions: Record<
  EmergencyStatus,
  EmergencyStatus[]
> = {
  PENDING: [
    "READY_FOR_ESCALATION",
    "CANCELLED",
  ],

  READY_FOR_ESCALATION: [
    "ESCALATING",
    "CONTACT_REACHED",
    "ESCALATION_EXHAUSTED",
    "CANCELLED",
  ],

  ESCALATING: [
    "ESCALATING",
    "CONTACT_REACHED",
    "ESCALATION_EXHAUSTED",
    "CANCELLED",
  ],

  CONTACT_REACHED: [],
  ESCALATION_EXHAUSTED: [],
  CANCELLED: [],
};

/**
 * Checks whether an emergency status transition is allowed.
 *
 * @param {EmergencyStatus} currentStatus Current emergency status.
 * @param {EmergencyStatus} nextStatus Requested emergency status.
 * @return {boolean} True when transition is allowed.
 */
function canTransitionEmergencyStatus(
  currentStatus: EmergencyStatus,
  nextStatus: EmergencyStatus
): boolean {
  return emergencyStatusTransitions[currentStatus]
    .includes(nextStatus);
}

export const healthCheck = onRequest(
  (request, response) => {
    logger.info(
      "Rapid Reach backend health check"
    );

    response.status(200).json({
      success: true,
      service: "rapid-reach-backend",
      status: "healthy",
    });
  }
);

export const authenticatedTest = onCall(
  (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "access this function."
      );
    }

    return {
      success: true,
      message:
        "Authentication verified successfully.",
      uid: request.auth.uid,
    };
  }
);

export const firestoreTest = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "access this function."
      );
    }

    const uid = request.auth.uid;

    await db
      .collection("users")
      .doc(uid)
      .set(
        {
          uid: uid,
          updatedAt:
            FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

    return {
      success: true,
      message:
        "Firestore connection verified " +
        "successfully.",
      uid: uid,
    };
  }
);

interface EmergencyEventData {
  eventId: string;
  eventType: string;
  timestamp: string;
  source: string;
  location?: {
    latitude: number;
    longitude: number;
  };
  sensorData?: {
    heartRate?: number;
    spo2?: number;
  };
}

interface ContactFeatures {
  contactId: string;
  displayName?: string;
  phoneHash: string;
  callCount: number;
  answeredCalls: number;
  missedCalls: number;
  totalDurationSeconds: number;
  lastContactAt?: string;
  communicationDays: number;
  isLikelyBusiness?: boolean;
  isLikelySpam?: boolean;
}

interface RankedContact {
  rank: number;
  contactId: string;
  displayName: string | null;
  trustScore: number;
  phoneHash: string | null;
  isLikelyBusiness: boolean;
  isLikelySpam: boolean;
}

interface EscalationRequest {
  eventId: string;
}

interface EscalationProgressRequest {
  eventId: string;
  attemptResult:
    | "ANSWERED"
    | "NO_RESPONSE"
    | "FAILED";
}

interface CancelEmergencyRequest {
  eventId: string;
  reason?: string;
}

interface GetEmergencyStatusRequest {
  eventId: string;
}

interface RegisterDeviceTokenRequest {
  deviceId: string;
  token: string;
  platform?:
    | "android"
    | "ios"
    | "web"
    | "unknown";
}

type EmergencyNotificationType =
  | "EMERGENCY_STARTED"
  | "ESCALATION_READY"
  | "ESCALATION_PROGRESS"
  | "CONTACT_REACHED"
  | "ESCALATION_EXHAUSTED"
  | "EMERGENCY_CANCELLED";

interface EmergencyNotificationPayload {
  type: EmergencyNotificationType;
  eventId: string;
  eventType: string;
  status: EmergencyStatus;
  title: string;
  body: string;
  source: string;
  timestamp: string;
}

interface SendEmergencyNotificationRequest {
  eventId: string;
}

interface NotificationSendResult {
  notificationType: EmergencyNotificationType;
  targetCount: number;
  successCount: number;
  failureCount: number;
  invalidTokenCount: number;
  notificationLogId: string;
}

interface EscalationPlanItem {
  escalationOrder: number;
  contactId: string;
  displayName: string | null;
  phoneHash: string | null;
  trustScore: number;
  isLikelyBusiness: boolean;
  status: string;
}

interface AttemptHistoryItem {
  escalationOrder: number;
  contactId: string;
  displayName: string | null;
  trustScore: number;
  result:
    | "ANSWERED"
    | "NO_RESPONSE"
    | "FAILED";
  attemptedAt: Timestamp;
}

interface StatusHistoryItem {
  fromStatus: EmergencyStatus | null;
  toStatus: EmergencyStatus;
  changedAt: Timestamp;
  reason: string;
}

/**
 * Creates an emergency status history entry.
 *
 * @param {EmergencyStatus|null} fromStatus Previous status.
 * @param {EmergencyStatus} toStatus New status.
 * @param {string} reason Transition reason.
 * @return {StatusHistoryItem} Status history item.
 */
function createStatusHistoryItem(
  fromStatus: EmergencyStatus | null,
  toStatus: EmergencyStatus,
  reason: string
): StatusHistoryItem {
  return {
    fromStatus: fromStatus,
    toStatus: toStatus,
    changedAt: Timestamp.now(),
    reason: reason,
  };
}

/**
 * Creates a consistent emergency notification payload.
 *
 * @param {EmergencyNotificationType} type Notification type.
 * @param {string} eventId Emergency event identifier.
 * @param {string} eventType Emergency event type.
 * @param {EmergencyStatus} status Current emergency status.
 * @param {string} source Emergency source.
 * @param {string} timestamp Emergency timestamp.
 * @return {EmergencyNotificationPayload} Notification payload.
 */
function createEmergencyNotificationPayload(
  type: EmergencyNotificationType,
  eventId: string,
  eventType: string,
  status: EmergencyStatus,
  source: string,
  timestamp: string
): EmergencyNotificationPayload {
  const messages: Record<
    EmergencyNotificationType,
    {
      title: string;
      body: string;
    }
  > = {
    EMERGENCY_STARTED: {
      title: "Rapid Reach Emergency",
      body: "An emergency event has been started.",
    },
    ESCALATION_READY: {
      title: "Emergency Escalation Ready",
      body: "Emergency contacts are ready for escalation.",
    },
    ESCALATION_PROGRESS: {
      title: "Emergency Escalation",
      body: "Rapid Reach is trying the next emergency contact.",
    },
    CONTACT_REACHED: {
      title: "Emergency Contact Reached",
      body: "An emergency contact has answered.",
    },
    ESCALATION_EXHAUSTED: {
      title: "Emergency Escalation Exhausted",
      body: "No emergency contact could be reached.",
    },
    EMERGENCY_CANCELLED: {
      title: "Emergency Cancelled",
      body: "The emergency event has been cancelled.",
    },
  };

  const message = messages[type];

  return {
    type: type,
    eventId: eventId,
    eventType: eventType,
    status: status,
    title: message.title,
    body: message.body,
    source: source,
    timestamp: timestamp,
  };
}

/**
 * Maps emergency status to notification type.
 *
 * @param {EmergencyStatus} status Current emergency status.
 * @return {EmergencyNotificationType} Notification type.
 */
function getNotificationTypeForStatus(
  status: EmergencyStatus
): EmergencyNotificationType {
  switch (status) {
  case "PENDING":
    return "EMERGENCY_STARTED";

  case "READY_FOR_ESCALATION":
    return "ESCALATION_READY";

  case "ESCALATING":
    return "ESCALATION_PROGRESS";

  case "CONTACT_REACHED":
    return "CONTACT_REACHED";

  case "ESCALATION_EXHAUSTED":
    return "ESCALATION_EXHAUSTED";

  case "CANCELLED":
    return "EMERGENCY_CANCELLED";
  }
}

/**
 * Attempts to send an emergency FCM notification.
 *
 * Notification failure must never roll back or break
 * the underlying emergency workflow.
 *
 * @param {string} uid Authenticated user identifier.
 * @param {string} eventId Emergency identifier.
 * @param {string} eventType Emergency event type.
 * @param {EmergencyStatus} status Emergency status.
 * @param {string} source Emergency event source.
 * @param {string} timestamp Emergency timestamp.
 * @return {Promise<NotificationSendResult>} Send result.
 */
async function sendEmergencyNotificationToUser(
  uid: string,
  eventId: string,
  eventType: string,
  status: EmergencyStatus,
  source: string,
  timestamp: string
): Promise<NotificationSendResult> {
  const notificationType =
    getNotificationTypeForStatus(
      status
    );

  const notificationPayload =
    createEmergencyNotificationPayload(
      notificationType,
      eventId,
      eventType,
      status,
      source,
      timestamp
    );

  const devicesSnapshot =
    await db
      .collection("users")
      .doc(uid)
      .collection("devices")
      .where(
        "enabled",
        "==",
        true
      )
      .get();

  const tokenToDeviceIds =
    new Map<string, string[]>();

  devicesSnapshot.docs.forEach(
    (deviceDoc) => {
      const token =
        deviceDoc.data().fcmToken;

      if (
        typeof token !== "string" ||
        token.trim().length === 0
      ) {
        return;
      }

      const normalizedToken =
        token.trim();

      const deviceIds =
        tokenToDeviceIds.get(
          normalizedToken
        ) ?? [];

      deviceIds.push(
        deviceDoc.id
      );

      tokenToDeviceIds.set(
        normalizedToken,
        deviceIds
      );
    }
  );

  const tokens =
    Array.from(
      tokenToDeviceIds.keys()
    );

  const notificationLogRef =
    db
      .collection("users")
      .doc(uid)
      .collection("notificationLogs")
      .doc();

  await notificationLogRef.set({
    eventId: eventId,
    eventType: eventType,
    notificationType:
      notificationType,
    status: status,
    source: source,
    timestamp: timestamp,
    targetCount:
      tokens.length,
    successCount: 0,
    failureCount: 0,
    invalidTokenCount: 0,
    result: "PENDING_SEND",
    createdAt:
      FieldValue.serverTimestamp(),
    updatedAt:
      FieldValue.serverTimestamp(),
  });

  if (tokens.length === 0) {
    await notificationLogRef.set(
      {
        result:
          "SKIPPED_NO_ENABLED_DEVICE_TOKENS",
        updatedAt:
          FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

    logger.info(
      "Emergency notification skipped",
      {
        uid: uid,
        eventId: eventId,
        notificationType:
          notificationType,
        notificationLogId:
          notificationLogRef.id,
        reason:
          "NO_ENABLED_DEVICE_TOKENS",
      }
    );

    return {
      notificationType:
        notificationType,
      targetCount: 0,
      successCount: 0,
      failureCount: 0,
      invalidTokenCount: 0,
      notificationLogId:
        notificationLogRef.id,
    };
  }

  const messaging =
    getMessaging();

  let successCount = 0;
  let failureCount = 0;

  const invalidTokens =
    new Set<string>();

  const permanentTokenErrors =
    new Set([
      "messaging/registration-token-not-registered",
      "messaging/invalid-registration-token",
    ]);

  const batchSize = 500;

  for (
    let startIndex = 0;
    startIndex < tokens.length;
    startIndex += batchSize
  ) {
    const batchTokens =
      tokens.slice(
        startIndex,
        startIndex + batchSize
      );

    try {
      const response =
        await messaging
          .sendEachForMulticast({
            tokens:
              batchTokens,
            notification: {
              title:
                notificationPayload.title,
              body:
                notificationPayload.body,
            },
            data: {
              type:
                notificationPayload.type,
              eventId:
                notificationPayload.eventId,
              eventType:
                notificationPayload.eventType,
              status:
                notificationPayload.status,
              source:
                notificationPayload.source,
              timestamp:
                notificationPayload.timestamp,
            },
          });

      successCount +=
        response.successCount;

      failureCount +=
        response.failureCount;

      response.responses.forEach(
        (sendResponse, index) => {
          if (
            sendResponse.success ||
            !sendResponse.error
          ) {
            return;
          }

          const errorCode =
            sendResponse.error.code;

          if (
            permanentTokenErrors.has(
              errorCode
            )
          ) {
            const token =
              batchTokens[index];

            if (token) {
              invalidTokens.add(
                token
              );
            }
          }
        }
      );
    } catch (error) {
      failureCount +=
        batchTokens.length;

      logger.error(
        "Emergency FCM batch failed",
        {
          uid: uid,
          eventId: eventId,
          notificationType:
            notificationType,
          notificationLogId:
            notificationLogRef.id,
          batchTargetCount:
            batchTokens.length,
          error: error,
        }
      );
    }
  }

  let invalidTokenCount = 0;

  for (
    const invalidToken of
    invalidTokens
  ) {
    const deviceIds =
      tokenToDeviceIds.get(
        invalidToken
      ) ?? [];

    for (
      const deviceId of
      deviceIds
    ) {
      const deviceRef =
        db
          .collection("users")
          .doc(uid)
          .collection("devices")
          .doc(deviceId);

      await deviceRef.set(
        {
          enabled: false,
          invalidatedAt:
            FieldValue.serverTimestamp(),
          invalidReason:
            "FCM_TOKEN_INVALID_OR_EXPIRED",
          updatedAt:
            FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      invalidTokenCount += 1;
    }
  }

  const result =
    failureCount === 0 ?
      "SUCCESS" :
      successCount > 0 ?
        "PARTIAL_FAILURE" :
        "FAILED";

  await notificationLogRef.set(
    {
      targetCount:
        tokens.length,
      successCount:
        successCount,
      failureCount:
        failureCount,
      invalidTokenCount:
        invalidTokenCount,
      result: result,
      updatedAt:
        FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  logger.info(
    "Emergency FCM notification attempted",
    {
      uid: uid,
      eventId: eventId,
      notificationType:
        notificationType,
      notificationLogId:
        notificationLogRef.id,
      targetCount:
        tokens.length,
      successCount:
        successCount,
      failureCount:
        failureCount,
      invalidTokenCount:
        invalidTokenCount,
    }
  );

  return {
    notificationType:
      notificationType,
    targetCount:
      tokens.length,
    successCount:
      successCount,
    failureCount:
      failureCount,
    invalidTokenCount:
      invalidTokenCount,
    notificationLogId:
      notificationLogRef.id,
  };
}

/**
 * Restricts a score to 0-100.
 *
 * @param {number} value Score value.
 * @return {number} Restricted score.
 */
function clampScore(value: number): number {
  return Math.max(
    0,
    Math.min(100, value)
  );
}

/**
 * Calculates answer-rate score.
 *
 * @param {number} answeredCalls Answered calls.
 * @param {number} callCount Total calls.
 * @return {number} Answer-rate score.
 */
function calculateAnswerRateScore(
  answeredCalls: number,
  callCount: number
): number {
  if (callCount <= 0) {
    return 0;
  }

  return clampScore(
    (answeredCalls / callCount) * 100
  );
}

/**
 * Calculates frequency score.
 *
 * @param {number} callCount Total calls.
 * @return {number} Frequency score.
 */
function calculateFrequencyScore(
  callCount: number
): number {
  if (callCount <= 0) {
    return 0;
  }

  const frequencyThreshold = 50;

  return clampScore(
    (callCount / frequencyThreshold) *
    100
  );
}

/**
 * Calculates duration score.
 *
 * @param {number} totalDurationSeconds Duration.
 * @return {number} Duration score.
 */
function calculateDurationScore(
  totalDurationSeconds: number
): number {
  if (totalDurationSeconds <= 0) {
    return 0;
  }

  const durationThresholdSeconds = 7200;

  return clampScore(
    (
      totalDurationSeconds /
      durationThresholdSeconds
    ) * 100
  );
}

/**
 * Calculates consistency score.
 *
 * @param {number} communicationDays Days.
 * @return {number} Consistency score.
 */
function calculateConsistencyScore(
  communicationDays: number
): number {
  if (communicationDays <= 0) {
    return 0;
  }

  const consistencyThresholdDays = 30;

  return clampScore(
    (
      communicationDays /
      consistencyThresholdDays
    ) * 100
  );
}

/**
 * Calculates recency score.
 *
 * @param {string|undefined} lastContactAt Last contact.
 * @return {number} Recency score.
 */
function calculateRecencyScore(
  lastContactAt?: string
): number {
  if (!lastContactAt) {
    return 0;
  }

  const lastContactTime =
    new Date(lastContactAt).getTime();

  if (Number.isNaN(lastContactTime)) {
    return 0;
  }

  const now = Date.now();

  const millisecondsPerDay =
    24 * 60 * 60 * 1000;

  const daysSinceLastContact =
    Math.max(
      0,
      (
        now -
        lastContactTime
      ) / millisecondsPerDay
    );

  const recencyThresholdDays = 30;

  const score =
    100 -
    (
      daysSinceLastContact /
      recencyThresholdDays
    ) * 100;

  return Math.round(
    clampScore(score)
  );
}

/**
 * Calculates spam/business reliability.
 *
 * @param {boolean} isLikelyBusiness Business flag.
 * @param {boolean} isLikelySpam Spam flag.
 * @return {number} Reliability score.
 */
function calculateSpamBusinessScore(
  isLikelyBusiness: boolean,
  isLikelySpam: boolean
): number {
  if (isLikelySpam) {
    return 0;
  }

  if (isLikelyBusiness) {
    return 40;
  }

  return 100;
}

/**
 * Calculates weighted trust score.
 *
 * @param {number} answerRateScore Answer score.
 * @param {number} frequencyScore Frequency score.
 * @param {number} durationScore Duration score.
 * @param {number} consistencyScore Consistency score.
 * @param {number} recencyScore Recency score.
 * @param {number} spamBusinessScore Reliability score.
 * @return {number} Trust score.
 */
function calculateTrustScore(
  answerRateScore: number,
  frequencyScore: number,
  durationScore: number,
  consistencyScore: number,
  recencyScore: number,
  spamBusinessScore: number
): number {
  const weightedScore =
    answerRateScore * 0.25 +
    frequencyScore * 0.20 +
    durationScore * 0.15 +
    consistencyScore * 0.15 +
    recencyScore * 0.15 +
    spamBusinessScore * 0.10;

  return Math.round(
    clampScore(weightedScore)
  );
}

const MAX_EVENT_ID_LENGTH = 200;
const MAX_CONTACT_ID_LENGTH = 200;
const MAX_EVENT_TYPE_LENGTH = 100;
const MAX_SOURCE_LENGTH = 100;
const MAX_DISPLAY_NAME_LENGTH = 200;
const MAX_PHONE_HASH_LENGTH = 512;
const MAX_REASON_LENGTH = 500;
const MAX_TIMESTAMP_LENGTH = 64;

/**
 * Normalizes a required string input.
 *
 * @param {unknown} value Raw input value.
 * @param {string} fieldName Input field name.
 * @param {number} maxLength Maximum allowed length.
 * @return {string} Normalized string.
 */
function normalizeRequiredString(
  value: unknown,
  fieldName: string,
  maxLength: number
): string {
  if (typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is required.`
    );
  }

  const normalized = value.trim();

  if (!normalized) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is required.`
    );
  }

  if (normalized.length > maxLength) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is too long.`
    );
  }

  return normalized;
}

/**
 * Normalizes an optional string input.
 *
 * @param {unknown} value Raw input value.
 * @param {string} fieldName Input field name.
 * @param {number} maxLength Maximum allowed length.
 * @return {string|null} Normalized string or null.
 */
function normalizeOptionalString(
  value: unknown,
  fieldName: string,
  maxLength: number
): string | null {
  if (
    value === undefined ||
    value === null
  ) {
    return null;
  }

  if (typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} must be a string.`
    );
  }

  const normalized = value.trim();

  if (!normalized) {
    return null;
  }

  if (normalized.length > maxLength) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is too long.`
    );
  }

  return normalized;
}

/**
 * Normalizes an identifier used as a Firestore document ID.
 *
 * @param {unknown} value Raw identifier.
 * @param {string} fieldName Field name.
 * @param {number} maxLength Maximum length.
 * @return {string} Safe identifier.
 */
function normalizeDocumentId(
  value: unknown,
  fieldName: string,
  maxLength: number
): string {
  const normalized = normalizeRequiredString(
    value,
    fieldName,
    maxLength
  );

  if (normalized.includes("/")) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} cannot contain '/'.`
    );
  }

  return normalized;
}

/**
 * Validates and normalizes an ISO-compatible timestamp string.
 *
 * @param {unknown} value Raw timestamp.
 * @param {string} fieldName Field name.
 * @return {string} Normalized timestamp.
 */
function normalizeTimestamp(
  value: unknown,
  fieldName: string
): string {
  const normalized = normalizeRequiredString(
    value,
    fieldName,
    MAX_TIMESTAMP_LENGTH
  );

  if (Number.isNaN(Date.parse(normalized))) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} must be a valid timestamp.`
    );
  }

  return normalized;
}

/**
 * Validates a non-negative finite number.
 *
 * @param {unknown} value Raw numeric input.
 * @param {string} fieldName Field name.
 * @param {boolean} integerOnly Require an integer value.
 * @return {number} Validated number.
 */
function normalizeNonNegativeNumber(
  value: unknown,
  fieldName: string,
  integerOnly = false
): number {
  if (
    typeof value !== "number" ||
    !Number.isFinite(value) ||
    value < 0 ||
    (integerOnly && !Number.isInteger(value))
  ) {
    throw new HttpsError(
      "invalid-argument",
      integerOnly ?
        `${fieldName} must be a non-negative integer.` :
        `${fieldName} must be a non-negative number.`
    );
  }

  return value;
}

/**
 * Validates optional emergency location data.
 *
 * @param {Object|undefined} location Location input.
 * @return {Object|null} Validated location.
 */
function normalizeLocation(
  location: EmergencyEventData["location"]
): EmergencyEventData["location"] | null {
  if (location === undefined) {
    return null;
  }

  if (
    typeof location !== "object" ||
    location === null ||
    typeof location.latitude !== "number" ||
    !Number.isFinite(location.latitude) ||
    typeof location.longitude !== "number" ||
    !Number.isFinite(location.longitude) ||
    location.latitude < -90 ||
    location.latitude > 90 ||
    location.longitude < -180 ||
    location.longitude > 180
  ) {
    throw new HttpsError(
      "invalid-argument",
      "location must contain valid latitude and longitude."
    );
  }

  return {
    latitude: location.latitude,
    longitude: location.longitude,
  };
}

/**
 * Validates optional sensor readings.
 *
 * @param {Object|undefined} sensorData Sensor input.
 * @return {Object|null} Validated sensor data.
 */
function normalizeSensorData(
  sensorData: EmergencyEventData["sensorData"]
): EmergencyEventData["sensorData"] | null {
  if (sensorData === undefined) {
    return null;
  }

  if (
    typeof sensorData !== "object" ||
    sensorData === null
  ) {
    throw new HttpsError(
      "invalid-argument",
      "sensorData must be an object."
    );
  }

  const normalized: EmergencyEventData["sensorData"] = {};

  if (sensorData.heartRate !== undefined) {
    if (
      typeof sensorData.heartRate !== "number" ||
      !Number.isFinite(sensorData.heartRate) ||
      sensorData.heartRate < 0 ||
      sensorData.heartRate > 300
    ) {
      throw new HttpsError(
        "invalid-argument",
        "heartRate must be between 0 and 300."
      );
    }

    normalized.heartRate = sensorData.heartRate;
  }

  if (sensorData.spo2 !== undefined) {
    if (
      typeof sensorData.spo2 !== "number" ||
      !Number.isFinite(sensorData.spo2) ||
      sensorData.spo2 < 0 ||
      sensorData.spo2 > 100
    ) {
      throw new HttpsError(
        "invalid-argument",
        "spo2 must be between 0 and 100."
      );
    }

    normalized.spo2 = sensorData.spo2;
  }

  return normalized;
}

export const startEmergency = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "start an emergency."
      );
    }

    const data =
      (request.data ?? {}) as EmergencyEventData;

    const eventId =
      normalizeDocumentId(
        data.eventId,
        "eventId",
        MAX_EVENT_ID_LENGTH
      );

    const eventType =
      normalizeRequiredString(
        data.eventType,
        "eventType",
        MAX_EVENT_TYPE_LENGTH
      );

    const timestamp =
      normalizeTimestamp(
        data.timestamp,
        "timestamp"
      );

    const source =
      normalizeRequiredString(
        data.source,
        "source",
        MAX_SOURCE_LENGTH
      );

    const location =
      normalizeLocation(
        data.location
      );

    const sensorData =
      normalizeSensorData(
        data.sensorData
      );

    const uid =
      request.auth.uid;

    const emergencyRef =
      db
        .collection("users")
        .doc(uid)
        .collection("emergencies")
        .doc(eventId);

    const existingEmergency =
      await emergencyRef.get();

    if (existingEmergency.exists) {
      throw new HttpsError(
        "already-exists",
        "An emergency with this eventId " +
        "already exists."
      );
    }

    const initialStatus:
      EmergencyStatus =
        "PENDING";

    const initialHistory =
      createStatusHistoryItem(
        null,
        initialStatus,
        "EMERGENCY_STARTED"
      );

    await emergencyRef.set({
      eventId:
        eventId,
      userId:
        uid,
      eventType:
        eventType,
      timestamp:
        timestamp,
      source:
        source,
      location:
        location,
      sensorData:
        sensorData,
      status:
        initialStatus,
      statusHistory: [
        initialHistory,
      ],
      attemptHistory: [],
      statusChangedAt:
        FieldValue.serverTimestamp(),
      createdAt:
        FieldValue.serverTimestamp(),
      updatedAt:
        FieldValue.serverTimestamp(),
    });

    const notificationResult =
      await sendEmergencyNotificationToUser(
        uid,
        eventId,
        eventType,
        initialStatus,
        source,
        timestamp
      );

    logger.info(
      "Emergency started",
      {
        uid: uid,
        eventId: eventId,
        status: initialStatus,
        notificationResult:
          notificationResult,
      }
    );

    return {
      success: true,
      emergencyId:
        eventId,
      status:
        initialStatus,
    };
  }
);

export const saveContactFeatures = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "save contact features."
      );
    }

    const data =
      (request.data ?? {}) as ContactFeatures;

    const contactId =
      normalizeDocumentId(
        data.contactId,
        "contactId",
        MAX_CONTACT_ID_LENGTH
      );

    const phoneHash =
      normalizeRequiredString(
        data.phoneHash,
        "phoneHash",
        MAX_PHONE_HASH_LENGTH
      );

    const displayName =
      normalizeOptionalString(
        data.displayName,
        "displayName",
        MAX_DISPLAY_NAME_LENGTH
      );

    const uid =
      request.auth.uid;

    const callCount =
      normalizeNonNegativeNumber(
        data.callCount ?? 0,
        "callCount",
        true
      );

    const answeredCalls =
      normalizeNonNegativeNumber(
        data.answeredCalls ?? 0,
        "answeredCalls",
        true
      );

    const missedCalls =
      normalizeNonNegativeNumber(
        data.missedCalls ?? 0,
        "missedCalls",
        true
      );

    const totalDurationSeconds =
      normalizeNonNegativeNumber(
        data.totalDurationSeconds ?? 0,
        "totalDurationSeconds",
        true
      );

    const communicationDays =
      normalizeNonNegativeNumber(
        data.communicationDays ?? 0,
        "communicationDays",
        true
      );

    if (answeredCalls > callCount) {
      throw new HttpsError(
        "invalid-argument",
        "answeredCalls cannot exceed callCount."
      );
    }

    const lastContactAt =
      data.lastContactAt === undefined ?
        undefined :
        normalizeTimestamp(
          data.lastContactAt,
          "lastContactAt"
        );

    const isLikelyBusiness =
      data.isLikelyBusiness ?? false;

    const isLikelySpam =
      data.isLikelySpam ?? false;

    if (
      typeof isLikelyBusiness !== "boolean" ||
      typeof isLikelySpam !== "boolean"
    ) {
      throw new HttpsError(
        "invalid-argument",
        "isLikelyBusiness and isLikelySpam must be boolean values."
      );
    }

    const answerRateScore =
      calculateAnswerRateScore(
        answeredCalls,
        callCount
      );

    const frequencyScore =
      calculateFrequencyScore(
        callCount
      );

    const durationScore =
      calculateDurationScore(
        totalDurationSeconds
      );

    const consistencyScore =
      calculateConsistencyScore(
        communicationDays
      );

    const recencyScore =
      calculateRecencyScore(
        lastContactAt
      );

    const spamBusinessScore =
      calculateSpamBusinessScore(
        isLikelyBusiness,
        isLikelySpam
      );

    const trustScore =
      calculateTrustScore(
        answerRateScore,
        frequencyScore,
        durationScore,
        consistencyScore,
        recencyScore,
        spamBusinessScore
      );

    await db
      .collection("users")
      .doc(uid)
      .collection("contacts")
      .doc(contactId)
      .set(
        {
          contactId:
            contactId,
          displayName:
            displayName,
          phoneHash:
            phoneHash,
          callCount:
            callCount,
          answeredCalls:
            answeredCalls,
          missedCalls:
            missedCalls,
          totalDurationSeconds:
            totalDurationSeconds,
          lastContactAt:
            lastContactAt ?? null,
          communicationDays:
            communicationDays,
          isLikelyBusiness:
            isLikelyBusiness,
          isLikelySpam:
            isLikelySpam,
          answerRateScore:
            answerRateScore,
          frequencyScore:
            frequencyScore,
          durationScore:
            durationScore,
          consistencyScore:
            consistencyScore,
          recencyScore:
            recencyScore,
          spamBusinessScore:
            spamBusinessScore,
          trustScore:
            trustScore,
          updatedAt:
            FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

    return {
      success: true,
      contactId:
        contactId,
      answerRateScore:
        answerRateScore,
      frequencyScore:
        frequencyScore,
      durationScore:
        durationScore,
      consistencyScore:
        consistencyScore,
      recencyScore:
        recencyScore,
      spamBusinessScore:
        spamBusinessScore,
      trustScore:
        trustScore,
    };
  }
);

export const rankContacts = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "rank contacts."
      );
    }

    const uid =
      request.auth.uid;

    const snapshot =
      await db
        .collection("users")
        .doc(uid)
        .collection("contacts")
        .get();

    if (snapshot.empty) {
      return {
        success: true,
        totalContacts: 0,
        rankedContacts: [],
      };
    }

    const contacts =
      snapshot.docs.map(
        (doc) => {
          const data =
            doc.data();

          return {
            contactId:
              data.contactId ??
              doc.id,
            displayName:
              data.displayName ??
              null,
            phoneHash:
              data.phoneHash ??
              null,
            trustScore:
              typeof data.trustScore ===
              "number" ?
                data.trustScore :
                0,
            isLikelyBusiness:
              data.isLikelyBusiness ??
              false,
            isLikelySpam:
              data.isLikelySpam ??
              false,
          };
        }
      );

    contacts.sort(
      (a, b) => {
        return (
          b.trustScore -
          a.trustScore
        );
      }
    );

    const rankedContacts:
      RankedContact[] =
        contacts.map(
          (contact, index) => {
            return {
              rank:
                index + 1,
              contactId:
                contact.contactId,
              displayName:
                contact.displayName,
              trustScore:
                contact.trustScore,
              phoneHash:
                contact.phoneHash,
              isLikelyBusiness:
                contact.isLikelyBusiness,
              isLikelySpam:
                contact.isLikelySpam,
            };
          }
        );

    return {
      success: true,
      totalContacts:
        rankedContacts.length,
      rankedContacts:
        rankedContacts,
    };
  }
);

export const prepareEmergencyEscalation =
  onCall(
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "You must be signed in to " +
          "prepare emergency escalation."
        );
      }

      const data =
        (request.data ?? {}) as
          EscalationRequest;

      const eventId =
        normalizeDocumentId(
          data.eventId,
          "eventId",
          MAX_EVENT_ID_LENGTH
        );

      const uid =
        request.auth.uid;

      const emergencyRef =
        db
          .collection("users")
          .doc(uid)
          .collection("emergencies")
          .doc(eventId);

      const emergencySnapshot =
        await emergencyRef.get();

      if (
        !emergencySnapshot.exists
      ) {
        throw new HttpsError(
          "not-found",
          "Emergency event was not found."
        );
      }

      const emergencyData =
        emergencySnapshot.data();

      const currentStatus =
        emergencyData?.status as
          EmergencyStatus |
          undefined;

      if (!currentStatus) {
        throw new HttpsError(
          "failed-precondition",
          "Emergency status is missing."
        );
      }

      if (
        currentStatus !==
        "PENDING"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Escalation can only be " +
          "prepared for a PENDING emergency."
        );
      }

      if (
        !canTransitionEmergencyStatus(
          currentStatus,
          "READY_FOR_ESCALATION"
        )
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Emergency cannot transition " +
          "to READY_FOR_ESCALATION."
        );
      }

      const existingPlan =
        emergencyData
          ?.escalationPlan;

      if (
        Array.isArray(
          existingPlan
        ) &&
        existingPlan.length > 0
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Emergency escalation plan " +
          "already exists."
        );
      }

      const existingHistory =
        emergencyData
          ?.attemptHistory;

      if (
        Array.isArray(
          existingHistory
        ) &&
        existingHistory.length > 0
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Emergency already has " +
          "escalation attempts."
        );
      }

      if (
        typeof emergencyData
          ?.currentEscalationIndex ===
        "number"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Emergency escalation was " +
          "already initialized."
        );
      }

      const contactsSnapshot =
        await db
          .collection("users")
          .doc(uid)
          .collection("contacts")
          .get();

      if (
        contactsSnapshot.empty
      ) {
        throw new HttpsError(
          "failed-precondition",
          "No contacts are available " +
          "for emergency escalation."
        );
      }

      const eligibleContacts =
        contactsSnapshot.docs
          .map(
            (doc) => {
              const contact =
                doc.data();

              return {
                contactId:
                  contact.contactId ??
                  doc.id,
                displayName:
                  contact.displayName ??
                  null,
                phoneHash:
                  contact.phoneHash ??
                  null,
                trustScore:
                  typeof contact
                    .trustScore ===
                  "number" ?
                    contact.trustScore :
                    0,
                isLikelyBusiness:
                  contact
                    .isLikelyBusiness ??
                  false,
                isLikelySpam:
                  contact
                    .isLikelySpam ??
                  false,
              };
            }
          )
          .filter(
            (contact) => {
              return (
                !contact.isLikelySpam
              );
            }
          );

      if (
        eligibleContacts.length ===
        0
      ) {
        throw new HttpsError(
          "failed-precondition",
          "No eligible contacts are " +
          "available for escalation."
        );
      }

      eligibleContacts.sort(
        (a, b) => {
          return (
            b.trustScore -
            a.trustScore
          );
        }
      );

      const maximumEscalationContacts =
        3;

      const escalationPlan =
        eligibleContacts
          .slice(
            0,
            maximumEscalationContacts
          )
          .map(
            (contact, index) => {
              return {
                escalationOrder:
                  index + 1,
                contactId:
                  contact.contactId,
                displayName:
                  contact.displayName,
                phoneHash:
                  contact.phoneHash,
                trustScore:
                  contact.trustScore,
                isLikelyBusiness:
                  contact
                    .isLikelyBusiness,
                status:
                  "WAITING",
              };
            }
          );

      const statusHistoryItem =
        createStatusHistoryItem(
          currentStatus,
          "READY_FOR_ESCALATION",
          "ESCALATION_PREPARED"
        );

      await emergencyRef.set(
        {
          escalationPlan:
            escalationPlan,
          currentEscalationIndex:
            0,
          attemptHistory:
            [],
          status:
            "READY_FOR_ESCALATION",
          statusHistory:
            FieldValue.arrayUnion(
              statusHistoryItem
            ),
          statusChangedAt:
            FieldValue
              .serverTimestamp(),
          escalationPreparedAt:
            FieldValue
              .serverTimestamp(),
          updatedAt:
            FieldValue
              .serverTimestamp(),
        },
        {merge: true}
      );

      const eventType =
        typeof emergencyData
          ?.eventType ===
        "string" ?
          emergencyData.eventType :
          "UNKNOWN";

      const source =
        typeof emergencyData
          ?.source ===
        "string" ?
          emergencyData.source :
          "UNKNOWN";

      const timestamp =
        typeof emergencyData
          ?.timestamp ===
        "string" ?
          emergencyData.timestamp :
          new Date().toISOString();

      const notificationResult =
        await sendEmergencyNotificationToUser(
          uid,
          eventId,
          eventType,
          "READY_FOR_ESCALATION",
          source,
          timestamp
        );

      logger.info(
        "Emergency escalation prepared",
        {
          uid: uid,
          eventId:
            eventId,
          fromStatus:
            currentStatus,
          toStatus:
            "READY_FOR_ESCALATION",
          notificationResult:
            notificationResult,
        }
      );

      return {
        success: true,
        emergencyId:
          eventId,
        status:
          "READY_FOR_ESCALATION",
        totalEscalationContacts:
          escalationPlan.length,
        escalationPlan:
          escalationPlan,
      };
    }
  );

export const advanceEmergencyEscalation =
  onCall(
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "You must be signed in to " +
          "advance emergency escalation."
        );
      }

      const data =
        (request.data ?? {}) as
          EscalationProgressRequest;

      const eventId =
        normalizeDocumentId(
          data.eventId,
          "eventId",
          MAX_EVENT_ID_LENGTH
        );

      const attemptResult =
        normalizeRequiredString(
          data.attemptResult,
          "attemptResult",
          50
        );

      const allowedResults = [
        "ANSWERED",
        "NO_RESPONSE",
        "FAILED",
      ];

      if (
        !allowedResults.includes(
          attemptResult
        )
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Invalid attemptResult."
        );
      }

      const validatedAttemptResult =
        attemptResult as
          EscalationProgressRequest["attemptResult"];

      const uid =
        request.auth.uid;

      const emergencyRef =
        db
          .collection("users")
          .doc(uid)
          .collection("emergencies")
          .doc(eventId);

      const result =
        await db.runTransaction(
          async (transaction) => {
            const emergencySnapshot =
              await transaction.get(
                emergencyRef
              );

            if (
              !emergencySnapshot.exists
            ) {
              throw new HttpsError(
                "not-found",
                "Emergency event was not found."
              );
            }

            const emergencyData =
              emergencySnapshot.data();

            const currentStatus =
              emergencyData
                ?.status as
                EmergencyStatus |
                undefined;

            if (!currentStatus) {
              throw new HttpsError(
                "failed-precondition",
                "Emergency status is missing."
              );
            }

            if (
              currentStatus ===
                "CONTACT_REACHED" ||
              currentStatus ===
                "ESCALATION_EXHAUSTED" ||
              currentStatus ===
                "CANCELLED"
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Emergency escalation is " +
                "already complete."
              );
            }

            if (
              currentStatus !==
                "READY_FOR_ESCALATION" &&
              currentStatus !==
                "ESCALATING"
            ) {
              const message =
                "Emergency cannot be " +
                "escalated from status " +
                currentStatus +
                ".";

              throw new HttpsError(
                "failed-precondition",
                message
              );
            }

            const escalationPlan =
              emergencyData
                ?.escalationPlan as
                EscalationPlanItem[] |
                undefined;

            if (
              !escalationPlan ||
              escalationPlan.length ===
              0
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Emergency escalation plan " +
                "is not available."
              );
            }

            const currentIndex =
              typeof emergencyData
                ?.currentEscalationIndex ===
              "number" ?
                emergencyData
                  .currentEscalationIndex :
                0;

            if (
              currentIndex < 0 ||
              currentIndex >=
                escalationPlan.length
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Current escalation index " +
                "is invalid."
              );
            }

            const updatedPlan =
              escalationPlan.map(
                (item) => {
                  return {
                    ...item,
                  };
                }
              );

            const currentContact =
              updatedPlan[
                currentIndex
              ];

            const existingAttemptHistory =
              Array.isArray(
                emergencyData
                  ?.attemptHistory
              ) ?
                emergencyData
                  .attemptHistory as
                  AttemptHistoryItem[] :
                [];

            const attemptRecord:
              AttemptHistoryItem = {
                escalationOrder:
                  currentContact
                    .escalationOrder,
                contactId:
                  currentContact
                    .contactId,
                displayName:
                  currentContact
                    .displayName,
                trustScore:
                  currentContact
                    .trustScore,
                result:
                  validatedAttemptResult,
                attemptedAt:
                  Timestamp.now(),
              };

            const updatedAttemptHistory = [
              ...existingAttemptHistory,
              attemptRecord,
            ];

            if (
              validatedAttemptResult ===
              "ANSWERED"
            ) {
              if (
                !canTransitionEmergencyStatus(
                  currentStatus,
                  "CONTACT_REACHED"
                )
              ) {
                throw new HttpsError(
                  "failed-precondition",
                  "Invalid transition to " +
                  "CONTACT_REACHED."
                );
              }

              currentContact.status =
                "ANSWERED";

              const historyItem =
                createStatusHistoryItem(
                  currentStatus,
                  "CONTACT_REACHED",
                  "CONTACT_ANSWERED"
                );

              transaction.set(
                emergencyRef,
                {
                  escalationPlan:
                    updatedPlan,
                  attemptHistory:
                    updatedAttemptHistory,
                  currentEscalationIndex:
                    currentIndex,
                  status:
                    "CONTACT_REACHED",
                  statusHistory:
                    FieldValue
                      .arrayUnion(
                        historyItem
                      ),
                  statusChangedAt:
                    FieldValue
                      .serverTimestamp(),
                  contactedContactId:
                    currentContact
                      .contactId,
                  contactedAt:
                    FieldValue
                      .serverTimestamp(),
                  updatedAt:
                    FieldValue
                      .serverTimestamp(),
                },
                {merge: true}
              );

              return {
                success: true,
                emergencyId:
                  eventId,
                status:
                  "CONTACT_REACHED",
                currentContact:
                  currentContact,
                escalationComplete:
                  true,
                attemptHistoryCount:
                  updatedAttemptHistory
                    .length,
              };
            }

            if (
              validatedAttemptResult ===
              "NO_RESPONSE"
            ) {
              currentContact.status =
                "NO_RESPONSE";
            }

            if (
              validatedAttemptResult ===
              "FAILED"
            ) {
              currentContact.status =
                "FAILED";
            }

            const nextIndex =
              currentIndex + 1;

            if (
              nextIndex >=
              updatedPlan.length
            ) {
              if (
                !canTransitionEmergencyStatus(
                  currentStatus,
                  "ESCALATION_EXHAUSTED"
                )
              ) {
                throw new HttpsError(
                  "failed-precondition",
                  "Invalid transition to " +
                  "ESCALATION_EXHAUSTED."
                );
              }

              const historyItem =
                createStatusHistoryItem(
                  currentStatus,
                  "ESCALATION_EXHAUSTED",
                  "ALL_CONTACTS_EXHAUSTED"
                );

              transaction.set(
                emergencyRef,
                {
                  escalationPlan:
                    updatedPlan,
                  attemptHistory:
                    updatedAttemptHistory,
                  currentEscalationIndex:
                    currentIndex,
                  status:
                    "ESCALATION_EXHAUSTED",
                  statusHistory:
                    FieldValue
                      .arrayUnion(
                        historyItem
                      ),
                  statusChangedAt:
                    FieldValue
                      .serverTimestamp(),
                  updatedAt:
                    FieldValue
                      .serverTimestamp(),
                },
                {merge: true}
              );

              return {
                success: true,
                emergencyId:
                  eventId,
                status:
                  "ESCALATION_EXHAUSTED",
                escalationComplete:
                  true,
                nextContact:
                  null,
                attemptHistoryCount:
                  updatedAttemptHistory
                    .length,
              };
            }

            if (
              !canTransitionEmergencyStatus(
                currentStatus,
                "ESCALATING"
              )
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Invalid transition " +
                "to ESCALATING."
              );
            }

            updatedPlan[
              nextIndex
            ].status =
              "NEXT";

            const historyItem =
              createStatusHistoryItem(
                currentStatus,
                "ESCALATING",
                "NEXT_CONTACT_SELECTED"
              );

            transaction.set(
              emergencyRef,
              {
                escalationPlan:
                  updatedPlan,
                attemptHistory:
                  updatedAttemptHistory,
                currentEscalationIndex:
                  nextIndex,
                status:
                  "ESCALATING",
                statusHistory:
                  FieldValue
                    .arrayUnion(
                      historyItem
                    ),
                statusChangedAt:
                  FieldValue
                    .serverTimestamp(),
                updatedAt:
                  FieldValue
                    .serverTimestamp(),
              },
              {merge: true}
            );

            return {
              success: true,
              emergencyId:
                eventId,
              status:
                "ESCALATING",
              escalationComplete:
                false,
              currentEscalationIndex:
                nextIndex,
              nextContact:
                updatedPlan[
                  nextIndex
                ],
              attemptHistoryCount:
                updatedAttemptHistory
                  .length,
            };
          }
        );

      const updatedEmergencySnapshot =
        await emergencyRef.get();

      const updatedEmergencyData =
        updatedEmergencySnapshot.data();

      if (
        updatedEmergencyData
      ) {
        const eventType =
          typeof updatedEmergencyData
            .eventType ===
          "string" ?
            updatedEmergencyData
              .eventType :
            "UNKNOWN";

        const source =
          typeof updatedEmergencyData
            .source ===
          "string" ?
            updatedEmergencyData
              .source :
            "UNKNOWN";

        const timestamp =
          typeof updatedEmergencyData
            .timestamp ===
          "string" ?
            updatedEmergencyData
              .timestamp :
            new Date().toISOString();

        const notificationStatus =
          result.status as
            EmergencyStatus;

        await sendEmergencyNotificationToUser(
          uid,
          eventId,
          eventType,
          notificationStatus,
          source,
          timestamp
        );
      }

      logger.info(
        "Emergency escalation advanced",
        {
          uid: uid,
          eventId:
            eventId,
          attemptResult:
            validatedAttemptResult,
          status:
            result.status,
        }
      );

      return result;
    }
  );

export const cancelEmergency = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "cancel an emergency."
      );
    }

    const data =
      (request.data ?? {}) as
        CancelEmergencyRequest;

    const eventId =
      normalizeDocumentId(
        data.eventId,
        "eventId",
        MAX_EVENT_ID_LENGTH
      );

    const reason =
      normalizeOptionalString(
        data.reason,
        "reason",
        MAX_REASON_LENGTH
      );

    const uid =
      request.auth.uid;

    const emergencyRef =
      db
        .collection("users")
        .doc(uid)
        .collection("emergencies")
        .doc(eventId);

    const result =
      await db.runTransaction(
        async (transaction) => {
          const emergencySnapshot =
            await transaction.get(
              emergencyRef
            );

          if (
            !emergencySnapshot.exists
          ) {
            throw new HttpsError(
              "not-found",
              "Emergency event was not found."
            );
          }

          const emergencyData =
            emergencySnapshot.data();

          const currentStatus =
            emergencyData
              ?.status as
              EmergencyStatus |
              undefined;

          if (!currentStatus) {
            throw new HttpsError(
              "failed-precondition",
              "Emergency status is missing."
            );
          }

          if (
            currentStatus ===
            "CANCELLED"
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Emergency is already cancelled."
            );
          }

          if (
            currentStatus ===
              "CONTACT_REACHED" ||
            currentStatus ===
              "ESCALATION_EXHAUSTED"
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Completed emergency cannot " +
              "be cancelled."
            );
          }

          if (
            !canTransitionEmergencyStatus(
              currentStatus,
              "CANCELLED"
            )
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Emergency cannot be cancelled " +
              "from its current status."
            );
          }

          const historyItem =
            createStatusHistoryItem(
              currentStatus,
              "CANCELLED",
              "EMERGENCY_CANCELLED"
            );

          transaction.set(
            emergencyRef,
            {
              status:
                "CANCELLED",
              statusHistory:
                FieldValue
                  .arrayUnion(
                    historyItem
                  ),
              statusChangedAt:
                FieldValue
                  .serverTimestamp(),
              cancellationReason:
                reason,
              cancelledAt:
                FieldValue
                  .serverTimestamp(),
              updatedAt:
                FieldValue
                  .serverTimestamp(),
            },
            {merge: true}
          );

          return {
            success: true,
            emergencyId:
              eventId,
            previousStatus:
              currentStatus,
            status:
              "CANCELLED",
            reason:
              reason,
          };
        }
      );

    const updatedEmergencySnapshot =
      await emergencyRef.get();

    const updatedEmergencyData =
      updatedEmergencySnapshot.data();

    if (
      updatedEmergencyData
    ) {
      const eventType =
        typeof updatedEmergencyData
          .eventType ===
        "string" ?
          updatedEmergencyData
            .eventType :
          "UNKNOWN";

      const source =
        typeof updatedEmergencyData
          .source ===
        "string" ?
          updatedEmergencyData
            .source :
          "UNKNOWN";

      const timestamp =
        typeof updatedEmergencyData
          .timestamp ===
        "string" ?
          updatedEmergencyData
            .timestamp :
          new Date().toISOString();

      await sendEmergencyNotificationToUser(
        uid,
        eventId,
        eventType,
        "CANCELLED",
        source,
        timestamp
      );
    }

    logger.info(
      "Emergency cancelled",
      {
        uid: uid,
        eventId:
          eventId,
        previousStatus:
          result.previousStatus,
        reason:
          reason,
      }
    );

    return result;
  }
);

export const getEmergencyStatus = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "get emergency status."
      );
    }

    const data =
      (request.data ?? {}) as
        GetEmergencyStatusRequest;

    const eventId =
      normalizeDocumentId(
        data.eventId,
        "eventId",
        MAX_EVENT_ID_LENGTH
      );

    const uid =
      request.auth.uid;

    const emergencyRef =
      db
        .collection("users")
        .doc(uid)
        .collection("emergencies")
        .doc(eventId);

    const emergencySnapshot =
      await emergencyRef.get();

    if (
      !emergencySnapshot.exists
    ) {
      throw new HttpsError(
        "not-found",
        "Emergency event was not found."
      );
    }

    const emergencyData =
      emergencySnapshot.data();

    if (!emergencyData) {
      throw new HttpsError(
        "not-found",
        "Emergency data was not found."
      );
    }

    const status =
      emergencyData.status as
        EmergencyStatus |
        undefined;

    if (!status) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency status is missing."
      );
    }

    const escalationPlan =
      Array.isArray(
        emergencyData
          .escalationPlan
      ) ?
        emergencyData
          .escalationPlan :
        [];

    const attemptHistory =
      Array.isArray(
        emergencyData
          .attemptHistory
      ) ?
        emergencyData
          .attemptHistory :
        [];

    const statusHistory =
      Array.isArray(
        emergencyData
          .statusHistory
      ) ?
        emergencyData
          .statusHistory :
        [];

    const currentEscalationIndex =
      typeof emergencyData
        .currentEscalationIndex ===
      "number" ?
        emergencyData
          .currentEscalationIndex :
        null;

    return {
      success: true,
      emergencyId:
        eventId,
      status:
        status,
      eventType:
        emergencyData
          .eventType ??
        null,
      timestamp:
        emergencyData
          .timestamp ??
        null,
      source:
        emergencyData
          .source ??
        null,
      location:
        emergencyData
          .location ??
        null,
      sensorData:
        emergencyData
          .sensorData ??
        null,
      currentEscalationIndex:
        currentEscalationIndex,
      escalationPlan:
        escalationPlan,
      attemptHistory:
        attemptHistory,
      statusHistory:
        statusHistory,
      contactedContactId:
        emergencyData
          .contactedContactId ??
        null,
      cancellationReason:
        emergencyData
          .cancellationReason ??
        null,
      statusChangedAt:
        emergencyData
          .statusChangedAt ??
        null,
      escalationPreparedAt:
        emergencyData
          .escalationPreparedAt ??
        null,
      contactedAt:
        emergencyData
          .contactedAt ??
        null,
      cancelledAt:
        emergencyData
          .cancelledAt ??
        null,
      createdAt:
        emergencyData
          .createdAt ??
        null,
      updatedAt:
        emergencyData
          .updatedAt ??
        null,
    };
  }
);

/**
 * Registers or refreshes an authenticated user's
 * Firebase Cloud Messaging device token.
 */
export const registerDeviceToken = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "register a device token."
      );
    }

    const data =
      (request.data ?? {}) as
        RegisterDeviceTokenRequest;

    const deviceId =
      normalizeDocumentId(
        data.deviceId,
        "deviceId",
        200
      );

    const token =
      normalizeRequiredString(
        data.token,
        "FCM token",
        4096
      );

    const platform =
      data.platform === undefined ?
        "unknown" :
        normalizeRequiredString(
          data.platform,
          "platform",
          20
        ).toLowerCase();

    const allowedPlatforms = [
      "android",
      "ios",
      "web",
      "unknown",
    ];

    if (
      !allowedPlatforms.includes(
        platform
      )
    ) {
      throw new HttpsError(
        "invalid-argument",
        "platform must be android, ios, " +
        "web, or unknown."
      );
    }

    const uid =
      request.auth.uid;

    const deviceRef =
      db
        .collection("users")
        .doc(uid)
        .collection("devices")
        .doc(deviceId);

    const existingDevice =
      await deviceRef.get();

    const createdAt =
      existingDevice.exists ?
        existingDevice
          .data()
          ?.createdAt ??
          FieldValue
            .serverTimestamp() :
        FieldValue
          .serverTimestamp();

    await deviceRef.set(
      {
        deviceId:
          deviceId,
        fcmToken:
          token,
        platform:
          platform,
        enabled:
          true,
        createdAt:
          createdAt,
        tokenUpdatedAt:
          FieldValue
            .serverTimestamp(),
        updatedAt:
          FieldValue
            .serverTimestamp(),
      },
      {merge: true}
    );

    logger.info(
      "FCM device token registered",
      {
        uid: uid,
        deviceId:
          deviceId,
        platform:
          platform,
      }
    );

    return {
      success: true,
      deviceId:
        deviceId,
      platform:
        platform,
      enabled:
        true,
    };
  }
);

/**
 * Manually sends a notification for an emergency.
 */
export const sendEmergencyNotification = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to " +
        "send an emergency notification."
      );
    }

    const data =
      (request.data ?? {}) as
        SendEmergencyNotificationRequest;

    const eventId =
      normalizeDocumentId(
        data.eventId,
        "eventId",
        MAX_EVENT_ID_LENGTH
      );

    const uid =
      request.auth.uid;

    const emergencyRef =
      db
        .collection("users")
        .doc(uid)
        .collection("emergencies")
        .doc(eventId);

    const emergencySnapshot =
      await emergencyRef.get();

    if (
      !emergencySnapshot.exists
    ) {
      throw new HttpsError(
        "not-found",
        "Emergency event was not found."
      );
    }

    const emergencyData =
      emergencySnapshot.data();

    if (!emergencyData) {
      throw new HttpsError(
        "not-found",
        "Emergency data was not found."
      );
    }

    const status =
      emergencyData.status as
        EmergencyStatus |
        undefined;

    if (!status) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency status is missing."
      );
    }

    const eventType =
      typeof emergencyData
        .eventType ===
      "string" ?
        emergencyData
          .eventType :
        "UNKNOWN";

    const source =
      typeof emergencyData
        .source ===
      "string" ?
        emergencyData
          .source :
        "UNKNOWN";

    const timestamp =
      typeof emergencyData
        .timestamp ===
      "string" ?
        emergencyData
          .timestamp :
        new Date().toISOString();

    const notificationResult =
      await sendEmergencyNotificationToUser(
        uid,
        eventId,
        eventType,
        status,
        source,
        timestamp
      );

    return {
      success:
        notificationResult
          .failureCount === 0 &&
        notificationResult
          .successCount > 0,
      emergencyId:
        eventId,
      notificationType:
        notificationResult
          .notificationType,
      targetCount:
        notificationResult
          .targetCount,
      successCount:
        notificationResult
          .successCount,
      failureCount:
        notificationResult
          .failureCount,
      invalidTokenCount:
        notificationResult
          .invalidTokenCount,
      notificationLogId:
        notificationResult
          .notificationLogId,
    };
  }
);

