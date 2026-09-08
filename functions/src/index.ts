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