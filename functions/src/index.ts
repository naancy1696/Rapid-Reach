import {onRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

initializeApp();

const db = getFirestore();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

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

        isLikelyBusiness: data.isLikelyBusiness ?? false,
        isLikelySpam: data.isLikelySpam ?? false,

        answerRateScore: answerRateScore,
        frequencyScore: frequencyScore,
        durationScore: durationScore,
        consistencyScore: consistencyScore,
        recencyScore: recencyScore,

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
  };
});
