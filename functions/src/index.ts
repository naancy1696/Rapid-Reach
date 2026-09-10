import {onRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {
  getFirestore,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";

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
  return emergencyStatusTransitions[currentStatus].includes(nextStatus);
}

export const healthCheck = onRequest((request, response) => {
  logger.info("Rapid Reach backend health check");

  response.status(200).json({
    success: true,
    service: "rapid-reach-backend",
    status: "healthy",
  });
});

export const authenticatedTest = onCall((request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to access this function."
    );
  }

  return {
    success: true,
    message: "Authentication verified successfully.",
    uid: request.auth.uid,
  };
});

export const firestoreTest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to access this function."
    );
  }

  const uid = request.auth.uid;

  await db.collection("users").doc(uid).set(
    {
      uid: uid,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  return {
    success: true,
    message: "Firestore connection verified successfully.",
    uid: uid,
  };
});

interface EmergencyEventData {
  eventId: string;
  eventType: string;
  timestamp: string;
  source: string;
  status?: EmergencyStatus;
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
  attemptResult: "ANSWERED" | "NO_RESPONSE" | "FAILED";
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
  result: "ANSWERED" | "NO_RESPONSE" | "FAILED";
  attemptedAt: Timestamp;
}

/**
 * Restricts a score to the range 0 to 100.
 *
 * @param {number} value Score value.
 * @return {number} Score limited to 0-100.
 */
function clampScore(value: number): number {
  return Math.max(0, Math.min(100, value));
}

/**
 * Calculates the percentage of calls that were answered.
 *
 * @param {number} answeredCalls Number of answered calls.
 * @param {number} callCount Total number of calls.
 * @return {number} Answer-rate score from 0 to 100.
 */
function calculateAnswerRateScore(
  answeredCalls: number,
  callCount: number
): number {
  if (callCount <= 0) {
    return 0;
  }

  return clampScore((answeredCalls / callCount) * 100);
}

/**
 * Calculates communication-frequency score.
 *
 * A contact with 50 or more calls receives the maximum score.
 *
 * @param {number} callCount Total number of calls.
 * @return {number} Frequency score from 0 to 100.
 */
function calculateFrequencyScore(callCount: number): number {
  if (callCount <= 0) {
    return 0;
  }

  const frequencyThreshold = 50;

  return clampScore(
    (callCount / frequencyThreshold) * 100
  );
}

/**
 * Calculates communication-duration score.
 *
 * A total duration of 7200 seconds or more receives the maximum score.
 *
 * @param {number} totalDurationSeconds Total communication duration.
 * @return {number} Duration score from 0 to 100.
 */
function calculateDurationScore(totalDurationSeconds: number): number {
  if (totalDurationSeconds <= 0) {
    return 0;
  }

  const durationThresholdSeconds = 7200;

  return clampScore(
    (totalDurationSeconds / durationThresholdSeconds) * 100
  );
}

/**
 * Calculates communication-consistency score.
 *
 * A contact communicated with on 30 or more different days
 * receives the maximum score.
 *
 * @param {number} communicationDays Number of communication days.
 * @return {number} Consistency score from 0 to 100.
 */
function calculateConsistencyScore(communicationDays: number): number {
  if (communicationDays <= 0) {
    return 0;
  }

  const consistencyThresholdDays = 30;

  return clampScore(
    (communicationDays / consistencyThresholdDays) * 100
  );
}

/**
 * Calculates communication-recency score.
 *
 * A recently contacted person receives a higher score.
 * Contacts older than 30 days receive a score of zero.
 *
 * @param {string|undefined} lastContactAt Last contact timestamp.
 * @return {number} Recency score from 0 to 100.
 */
function calculateRecencyScore(
  lastContactAt?: string
): number {
  if (!lastContactAt) {
    return 0;
  }

  const lastContactTime = new Date(lastContactAt).getTime();

  if (Number.isNaN(lastContactTime)) {
    return 0;
  }

  const now = Date.now();
  const millisecondsPerDay = 24 * 60 * 60 * 1000;

  const daysSinceLastContact = Math.max(
    0,
    (now - lastContactTime) / millisecondsPerDay
  );

  const recencyThresholdDays = 30;

  const score =
    100 -
    (daysSinceLastContact / recencyThresholdDays) * 100;

  return Math.round(clampScore(score));
}

/**
 * Calculates the spam/business reliability score.
 *
 * Normal personal contacts receive 100.
 * Likely business contacts receive 40.
 * Likely spam contacts receive 0.
 *
 * @param {boolean} isLikelyBusiness Whether contact is likely a business.
 * @param {boolean} isLikelySpam Whether contact is likely spam.
 * @return {number} Reliability score from 0 to 100.
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
 * Calculates the final weighted trust score.
 *
 * Answer Rate = 25%
 * Frequency = 20%
 * Duration = 15%
 * Consistency = 15%
 * Recency = 15%
 * Spam/Business Reliability = 10%
 *
 * @param {number} answerRateScore Answer-rate score.
 * @param {number} frequencyScore Frequency score.
 * @param {number} durationScore Duration score.
 * @param {number} consistencyScore Consistency score.
 * @param {number} recencyScore Recency score.
 * @param {number} spamBusinessScore Reliability score.
 * @return {number} Final trust score from 0 to 100.
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

  return Math.round(clampScore(weightedScore));
}

export const startEmergency = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to start an emergency."
    );
  }

  const data = request.data as EmergencyEventData;

  if (
    !data.eventId ||
    !data.eventType ||
    !data.timestamp ||
    !data.source
  ) {
    throw new HttpsError(
      "invalid-argument",
      "eventId, eventType, timestamp, and source are required."
    );
  }

  const uid = request.auth.uid;

  await db
    .collection("users")
    .doc(uid)
    .collection("emergencies")
    .doc(data.eventId)
    .set({
      eventId: data.eventId,
      userId: uid,
      eventType: data.eventType,
      timestamp: data.timestamp,
      source: data.source,
      location: data.location ?? null,
      sensorData: data.sensorData ?? null,
      status: "PENDING",
      attemptHistory: [],
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

  return {
    success: true,
    emergencyId: data.eventId,
    status: "PENDING",
  };
});

export const saveContactFeatures = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to save contact features."
    );
  }

  const data = request.data as ContactFeatures;

  if (!data.contactId || !data.phoneHash) {
    throw new HttpsError(
      "invalid-argument",
      "contactId and phoneHash are required."
    );
  }

  const uid = request.auth.uid;

  const callCount = data.callCount ?? 0;
  const answeredCalls = data.answeredCalls ?? 0;
  const totalDurationSeconds = data.totalDurationSeconds ?? 0;
  const communicationDays = data.communicationDays ?? 0;
  const lastContactAt = data.lastContactAt;

  const isLikelyBusiness = data.isLikelyBusiness ?? false;
  const isLikelySpam = data.isLikelySpam ?? false;

  const answerRateScore = calculateAnswerRateScore(
    answeredCalls,
    callCount
  );

  const frequencyScore = calculateFrequencyScore(
    callCount
  );

  const durationScore = calculateDurationScore(
    totalDurationSeconds
  );

  const consistencyScore = calculateConsistencyScore(
    communicationDays
  );

  const recencyScore = calculateRecencyScore(
    lastContactAt
  );

  const spamBusinessScore = calculateSpamBusinessScore(
    isLikelyBusiness,
    isLikelySpam
  );

  const trustScore = calculateTrustScore(
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
    .doc(data.contactId)
    .set(
      {
        contactId: data.contactId,
        displayName: data.displayName ?? null,
        phoneHash: data.phoneHash,
        callCount: callCount,
        answeredCalls: answeredCalls,
        missedCalls: data.missedCalls ?? 0,
        totalDurationSeconds: totalDurationSeconds,
        lastContactAt: lastContactAt ?? null,
        communicationDays: communicationDays,
        isLikelyBusiness: isLikelyBusiness,
        isLikelySpam: isLikelySpam,
        answerRateScore: answerRateScore,
        frequencyScore: frequencyScore,
        durationScore: durationScore,
        consistencyScore: consistencyScore,
        recencyScore: recencyScore,
        spamBusinessScore: spamBusinessScore,
        trustScore: trustScore,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

  return {
    success: true,
    contactId: data.contactId,
    answerRateScore: answerRateScore,
    frequencyScore: frequencyScore,
    durationScore: durationScore,
    consistencyScore: consistencyScore,
    recencyScore: recencyScore,
    spamBusinessScore: spamBusinessScore,
    trustScore: trustScore,
  };
});

export const rankContacts = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be signed in to rank contacts."
    );
  }

  const uid = request.auth.uid;

  const snapshot = await db
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

  const contacts = snapshot.docs.map((doc) => {
    const data = doc.data();

    return {
      contactId: data.contactId ?? doc.id,
      displayName: data.displayName ?? null,
      phoneHash: data.phoneHash ?? null,
      trustScore:
        typeof data.trustScore === "number" ?
          data.trustScore :
          0,
      isLikelyBusiness: data.isLikelyBusiness ?? false,
      isLikelySpam: data.isLikelySpam ?? false,
    };
  });

  contacts.sort((a, b) => {
    return b.trustScore - a.trustScore;
  });

  const rankedContacts: RankedContact[] = contacts.map(
    (contact, index) => {
      return {
        rank: index + 1,
        contactId: contact.contactId,
        displayName: contact.displayName,
        trustScore: contact.trustScore,
        phoneHash: contact.phoneHash,
        isLikelyBusiness: contact.isLikelyBusiness,
        isLikelySpam: contact.isLikelySpam,
      };
    }
  );

  return {
    success: true,
    totalContacts: rankedContacts.length,
    rankedContacts: rankedContacts,
  };
});

export const prepareEmergencyEscalation = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to prepare emergency escalation."
      );
    }

    const data = request.data as EscalationRequest;

    if (!data.eventId) {
      throw new HttpsError(
        "invalid-argument",
        "eventId is required."
      );
    }

    const uid = request.auth.uid;

    const emergencyRef = db
      .collection("users")
      .doc(uid)
      .collection("emergencies")
      .doc(data.eventId);

    const emergencySnapshot = await emergencyRef.get();

    if (!emergencySnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Emergency event was not found."
      );
    }

    const emergencyData = emergencySnapshot.data();

    const currentStatus =
      emergencyData?.status as EmergencyStatus | undefined;

    if (!currentStatus) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency status is missing."
      );
    }

    if (
      !canTransitionEmergencyStatus(
        currentStatus,
        "READY_FOR_ESCALATION"
      )
    ) {
      const message =
        "Invalid emergency state transition: " +
        `${currentStatus} -> READY_FOR_ESCALATION`;

      throw new HttpsError(
        "failed-precondition",
        message
      );
    }

    const contactsSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("contacts")
      .get();

    if (contactsSnapshot.empty) {
      throw new HttpsError(
        "failed-precondition",
        "No contacts are available for emergency escalation."
      );
    }

    const eligibleContacts = contactsSnapshot.docs
      .map((doc) => {
        const contact = doc.data();

        return {
          contactId: contact.contactId ?? doc.id,
          displayName: contact.displayName ?? null,
          phoneHash: contact.phoneHash ?? null,
          trustScore:
            typeof contact.trustScore === "number" ?
              contact.trustScore :
              0,
          isLikelyBusiness:
            contact.isLikelyBusiness ?? false,
          isLikelySpam:
            contact.isLikelySpam ?? false,
        };
      })
      .filter((contact) => {
        return !contact.isLikelySpam;
      });

    if (eligibleContacts.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "No eligible contacts are available for escalation."
      );
    }

    eligibleContacts.sort((a, b) => {
      return b.trustScore - a.trustScore;
    });

    const maximumEscalationContacts = 3;

    const escalationPlan = eligibleContacts
      .slice(0, maximumEscalationContacts)
      .map((contact, index) => {
        return {
          escalationOrder: index + 1,
          contactId: contact.contactId,
          displayName: contact.displayName,
          phoneHash: contact.phoneHash,
          trustScore: contact.trustScore,
          isLikelyBusiness: contact.isLikelyBusiness,
          status: "WAITING",
        };
      });

    await emergencyRef.set(
      {
        escalationPlan: escalationPlan,
        currentEscalationIndex: 0,
        attemptHistory: [],
        status: "READY_FOR_ESCALATION",
        escalationPreparedAt:
          FieldValue.serverTimestamp(),
        updatedAt:
          FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

    return {
      success: true,
      emergencyId: data.eventId,
      status: "READY_FOR_ESCALATION",
      totalEscalationContacts:
        escalationPlan.length,
      escalationPlan: escalationPlan,
    };
  }
);

export const advanceEmergencyEscalation = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to advance emergency escalation."
      );
    }

    const data = request.data as EscalationProgressRequest;

    if (!data.eventId || !data.attemptResult) {
      throw new HttpsError(
        "invalid-argument",
        "eventId and attemptResult are required."
      );
    }

    const allowedResults = [
      "ANSWERED",
      "NO_RESPONSE",
      "FAILED",
    ];

    if (!allowedResults.includes(data.attemptResult)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid attemptResult."
      );
    }

    const uid = request.auth.uid;

    const emergencyRef = db
      .collection("users")
      .doc(uid)
      .collection("emergencies")
      .doc(data.eventId);

    const emergencySnapshot = await emergencyRef.get();

    if (!emergencySnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Emergency event was not found."
      );
    }

    const emergencyData = emergencySnapshot.data();

    const currentStatus =
      emergencyData?.status as EmergencyStatus | undefined;

    if (!currentStatus) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency status is missing."
      );
    }

    if (
      currentStatus === "CONTACT_REACHED" ||
      currentStatus === "ESCALATION_EXHAUSTED" ||
      currentStatus === "CANCELLED"
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency escalation is already complete."
      );
    }

    if (
      currentStatus !== "READY_FOR_ESCALATION" &&
      currentStatus !== "ESCALATING"
    ) {
      const message =
        "Emergency cannot be escalated from status " +
        currentStatus +
        ".";

      throw new HttpsError(
        "failed-precondition",
        message
      );
    }

    const escalationPlan =
      emergencyData?.escalationPlan as
        EscalationPlanItem[] | undefined;

    if (!escalationPlan || escalationPlan.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Emergency escalation plan is not available."
      );
    }

    const currentIndex =
      typeof emergencyData?.currentEscalationIndex === "number" ?
        emergencyData.currentEscalationIndex :
        0;

    if (
      currentIndex < 0 ||
      currentIndex >= escalationPlan.length
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Current escalation index is invalid."
      );
    }

    const updatedPlan = escalationPlan.map((item) => {
      return {...item};
    });

    const currentContact = updatedPlan[currentIndex];

    const existingAttemptHistory =
      Array.isArray(emergencyData?.attemptHistory) ?
        emergencyData.attemptHistory as AttemptHistoryItem[] :
        [];

    const attemptRecord: AttemptHistoryItem = {
      escalationOrder: currentContact.escalationOrder,
      contactId: currentContact.contactId,
      displayName: currentContact.displayName,
      trustScore: currentContact.trustScore,
      result: data.attemptResult,
      attemptedAt: Timestamp.now(),
    };

    const updatedAttemptHistory = [
      ...existingAttemptHistory,
      attemptRecord,
    ];

    if (data.attemptResult === "ANSWERED") {
      if (
        !canTransitionEmergencyStatus(
          currentStatus,
          "CONTACT_REACHED"
        )
      ) {
        const message =
          "Invalid emergency state transition: " +
          `${currentStatus} -> CONTACT_REACHED`;

        throw new HttpsError(
          "failed-precondition",
          message
        );
      }

      currentContact.status = "ANSWERED";

      await emergencyRef.set(
        {
          escalationPlan: updatedPlan,
          attemptHistory: updatedAttemptHistory,
          currentEscalationIndex: currentIndex,
          status: "CONTACT_REACHED",
          contactedContactId:
            currentContact.contactId,
          contactedAt:
            FieldValue.serverTimestamp(),
          updatedAt:
            FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      return {
        success: true,
        emergencyId: data.eventId,
        status: "CONTACT_REACHED",
        currentContact: currentContact,
        escalationComplete: true,
        attemptHistoryCount:
          updatedAttemptHistory.length,
      };
    }

    if (data.attemptResult === "NO_RESPONSE") {
      currentContact.status = "NO_RESPONSE";
    }

    if (data.attemptResult === "FAILED") {
      currentContact.status = "FAILED";
    }

    const nextIndex = currentIndex + 1;

    if (nextIndex >= updatedPlan.length) {
      if (
        !canTransitionEmergencyStatus(
          currentStatus,
          "ESCALATION_EXHAUSTED"
        )
      ) {
        const message =
          "Invalid emergency state transition: " +
          `${currentStatus} -> ESCALATION_EXHAUSTED`;

        throw new HttpsError(
          "failed-precondition",
          message
        );
      }

      await emergencyRef.set(
        {
          escalationPlan: updatedPlan,
          attemptHistory: updatedAttemptHistory,
          currentEscalationIndex: currentIndex,
          status: "ESCALATION_EXHAUSTED",
          updatedAt:
            FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      return {
        success: true,
        emergencyId: data.eventId,
        status: "ESCALATION_EXHAUSTED",
        escalationComplete: true,
        nextContact: null,
        attemptHistoryCount:
          updatedAttemptHistory.length,
      };
    }

    if (
      !canTransitionEmergencyStatus(
        currentStatus,
        "ESCALATING"
      )
    ) {
      const message =
        "Invalid emergency state transition: " +
        `${currentStatus} -> ESCALATING`;

      throw new HttpsError(
        "failed-precondition",
        message
      );
    }

    updatedPlan[nextIndex].status = "NEXT";

    await emergencyRef.set(
      {
        escalationPlan: updatedPlan,
        attemptHistory: updatedAttemptHistory,
        currentEscalationIndex: nextIndex,
        status: "ESCALATING",
        updatedAt:
          FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

    return {
      success: true,
      emergencyId: data.eventId,
      status: "ESCALATING",
      escalationComplete: false,
      currentEscalationIndex: nextIndex,
      nextContact: updatedPlan[nextIndex],
      attemptHistoryCount:
        updatedAttemptHistory.length,
    };
  }
);
