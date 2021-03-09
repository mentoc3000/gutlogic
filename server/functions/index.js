const admin = require('firebase-admin');
admin.initializeApp();

const functions = require('firebase-functions');
const food = require('./src/food');
const auth = require('./src/auth');
const pantry = require('./src/pantry');

exports.onUserDeleted = functions.auth.user().onDelete(auth.onUserDeleted);

exports.edamamFoodSearch = functions.https.onCall(food.edamamFoodSearch);

exports.onPantryEntryCreated = functions.firestore
  .document('/user_data/{userId}/pantry/{pantryId}')
  .onCreate(pantry.onPantryEntryCreated);

exports.onPantryEntryUpdated = functions.firestore
  .document('/user_data/{userId}/pantry/{pantryId}')
  .onUpdate(pantry.onPantryEntryUpdated);

exports.onPantryEntryDeleted = functions.firestore
  .document('/user_data/{userId}/pantry/{pantryId}')
  .onCreate(pantry.onPantryEntryDeleted);
