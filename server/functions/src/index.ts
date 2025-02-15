import * as admin from "firebase-admin";
import * as serviceAccount from "./firebase-adminsdk.json";

const serviceAccountCamel = {
  projectId: serviceAccount.project_id,
  clientEmail: serviceAccount.client_email,
  privateKey: serviceAccount.private_key,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountCamel),
});

import * as functions from "firebase-functions";
import * as food from "./food";
import * as auth from "./auth";
import * as iap from "./iap";
import {pubsubBillingTopic} from "./config.json";

export const onUserDeleted = functions.auth.user().onDelete(auth.onUserDeleted);

export const edamamFoodSearch = functions.https.onCall(food.edamamFoodSearch);

export const verifyPurchase = functions.https.onCall(iap.verifyPurchase);

export const handlePlayStoreServerEvent = functions.pubsub.topic(pubsubBillingTopic).onPublish(iap.handlePlayStoreServerEvent);