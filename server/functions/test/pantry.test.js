const test = require('ava');
const admin = require('firebase-admin');

const testHelpers = require('./_helpers');
const fft = testHelpers.firebaseFunctionsTest;

const myFunctions = require('../index');
const db = admin.firestore();
const testUserId = 'test-user-id';

test.after.always(async () => {
  // Do cleanup tasks.
  fft.cleanup();
});

test('updates pantry entry references when pantry entry is created', async (t) => {
  const foodId = 'food-id-1';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-1';
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [{ foodReference: { id: foodId } }, { foodReference: { id: 'food-id-0' } }],
  });
  const symptomEntryId = 'symptom-entry-id-1';
  await diary.doc(symptomEntryId).set({ $: 'SymptomEntry' });

  // Add a pantry entry
  const sensitivity = 2;
  const snap = fft.firestore.makeDocumentSnapshot({ sensitivity }, `user_data/${testUserId}/pantry/${foodId}`);
  const wrapped = fft.wrap(myFunctions.onPantryEntryCreated);
  const context = { params: { userId: testUserId, pantryId: foodId } };
  await wrapped(snap, context);

  // Check that pantry entry reference has been created
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference.sensitivity, sensitivity);
  t.is(mealEntry.mealElements[1].pantryEntryReference, undefined);
});

test('updates pantry entry references when pantry entry is updated', async (t) => {
  const foodId = 'food-id-2';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-2';
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [
      { foodReference: { id: foodId, pantryEntryReference: { sensitivity: 0 } } },
      { foodReference: { id: 'food-id-0' } },
    ],
  });
  const symptomEntryId = 'symptom-entry-id-2';
  await diary.doc(symptomEntryId).set({ $: 'SymptomEntry' });

  // Add a pantry entry
  const sensitivity = 2;
  const beforeSnap = fft.firestore.makeDocumentSnapshot({ sensitivity: 0 }, `user_data/${testUserId}/pantry/${foodId}`);
  const afterSnap = fft.firestore.makeDocumentSnapshot({ sensitivity }, `user_data/${testUserId}/pantry/${foodId}`);
  const change = fft.makeChange(beforeSnap, afterSnap);

  const wrapped = fft.wrap(myFunctions.onPantryEntryUpdated);
  const context = { params: { userId: testUserId, pantryId: foodId } };
  await wrapped(change, context);

  // Check that pantry entry reference has been updated
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference.sensitivity, sensitivity);
  t.is(mealEntry.mealElements[1].pantryEntryReference, undefined);
});

test('deletes pantry entry references when pantry entry is deleted', async (t) => {
  const foodId = 'food-id-3';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-3';
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [
      { foodReference: { id: foodId, pantryEntryReference: { sensitivity: 0 } } },
      { foodReference: { id: 'food-id-0' } },
    ],
  });

  // Add a pantry entry
  const snap = fft.firestore.makeDocumentSnapshot({ sensitivity: 0 }, `user_data/${testUserId}/pantry/${foodId}`);

  const wrapped = fft.wrap(myFunctions.onPantryEntryDeleted);
  const context = { params: { userId: testUserId, pantryId: foodId } };
  await wrapped(snap, context);

  // Check that pantry entry reference has been deleted
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference, undefined);
});
