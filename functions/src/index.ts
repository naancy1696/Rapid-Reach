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
        callCount: data.callCount ?? 0,
        answeredCalls: data.answeredCalls ?? 0,
        missedCalls: data.missedCalls ?? 0,
        totalDurationSeconds: data.totalDurationSeconds ?? 0,
        lastContactAt: data.lastContactAt ?? null,
        communicationDays: data.communicationDays ?? 0,
        isLikelyBusiness: data.isLikelyBusiness ?? false,
        isLikelySpam: data.isLikelySpam ?? false,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );

  return {
    success: true,
    contactId: data.contactId,
  };
});
