import * as admin from "firebase-admin";
admin.initializeApp();

import * as functions from "firebase-functions";
import * as food from "./food";
import * as auth from "./auth";

export const onUserDeleted = functions.auth.user().onDelete(auth.onUserDeleted);

export const edamamFoodSearch = functions.https.onCall(food.edamamFoodSearch);
