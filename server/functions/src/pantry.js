const admin = require('firebase-admin');
const db = admin.firestore();

/**
 * Create pantry references when pantry entry is created
 */
exports.onPantryEntryCreated = (snap, context) => {
  const userId = context.params.userId;
  const pantryId = context.params.pantryId;
  const pantryData = snap.data();
  return updatePantryEntryRefs(userId, pantryId, pantryData);
};

/**
 * Update pantry references when pantry entry is updated
 */
exports.onPantryEntryUpdated = (change, context) => {
  const userId = context.params.userId;
  const pantryData = change.after.data();
  const pantryId = context.params.pantryId;
  return updatePantryEntryRefs(userId, pantryId, pantryData);
};

/**
 * Delete pantry references when pantry entry is deleted
 */
exports.onPantryEntryDeleted = (snap, context) => {
  const userId = context.params.userId;
  const pantryId = context.params.pantryId;
  return deletePantryEntryRefs(userId, pantryId);
};

/**
 * Update pantry entry references
 */
const updatePantryEntryRefs = async (userId, pantryId, pantryData) => {
  const querySnapshot = await db.collection(`user_data/${userId}/diary`).where('$', '==', 'MealEntry').get();
  const foodReference = pantryData.foodReference;
  const foodId = foodReference.id;
  const foodName = foodReference.name;
  const batch = db.batch();

  querySnapshot.docs.forEach((doc) => {
    const mealEntry = doc.data();
    var containsUpdates = false;

    mealEntry.mealElements.forEach((mealElement, index) => {
      if (mealElement.foodReference.id === foodId && mealElement.foodReference.name === foodName) {
        if (!('pantryEntryReference' in mealElement)) {
          // Create pantry reference if it doesn't exist
          mealEntry.mealElements[index].pantryEntryReference = {
            id: pantryId,
            sensitivity: pantryData.sensitivity,
          };
          containsUpdates = true;
        } else {
          // Update the sensitivity, if it has changed
          if (
            !('sensitivity' in mealElement.pantryEntryReference) ||
            mealElement.pantryEntryReference.sensitivity !== pantryData.sensitivity
          ) {
            mealEntry.mealElements[index].pantryEntryReference.sensitivity = pantryData.sensitivity;
            containsUpdates = true;
          }
        }
      }
    });

    if (containsUpdates) {
      batch.update(doc.ref, mealEntry);
    }
  });

  await batch.commit();
};

/**
 * Delete pantry entry references
 */
const deletePantryEntryRefs = async (userId, pantryId) => {
  const querySnapshot = await db.collection(`user_data/${userId}/diary`).where('$', '==', 'MealEntry').get();
  const batch = db.batch();

  querySnapshot.docs.forEach((doc) => {
    const mealEntry = doc.data();
    var containsUpdates = false;

    mealEntry.mealElements.forEach((mealElement, index) => {
      if ('pantryEntryReference' in mealElement && mealElement.pantryEntryReference.id === pantryId) {
        delete mealEntry.mealElements[index].pantryEntryReference;
        containsUpdates = true;
      }
    });

    if (containsUpdates) {
      batch.update(doc.ref, mealEntry);
    }
  });

  await batch.commit();
};
