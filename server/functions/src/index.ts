const admin = require("firebase-admin");
admin.initializeApp();

const functions = require("firebase-functions");
const food = require("./food");
const auth = require("./auth");

exports.onUserDeleted = functions.auth.user().onDelete(auth.onUserDeleted);

exports.edamamFoodSearch = functions.https.onCall(food.edamamFoodSearch);
