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
  const foodName = 'chickpea';
  const pantryId = 'pantry-id-1';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-1';
  const foodReference = { id: foodId, name: foodName };
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [{ foodReference }, { foodReference: { id: 'food-id-0' } }],
  });
  const symptomEntryId = 'symptom-entry-id-1';
  await diary.doc(symptomEntryId).set({ $: 'SymptomEntry' });

  // Add a pantry entry
  const sensitivity = 2;
  const pantryEntry = { id: pantryId, foodReference, sensitivity };
  const snap = fft.firestore.makeDocumentSnapshot(pantryEntry, `user_data/${testUserId}/pantry/${pantryId}`);
  const wrapped = fft.wrap(myFunctions.onPantryEntryCreated);
  const context = { params: { userId: testUserId, pantryId: pantryId } };
  await wrapped(snap, context);

  // Check that pantry entry reference has been created
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference.sensitivity, sensitivity);
  t.is(mealEntry.mealElements[1].pantryEntryReference, undefined);
});

test('updates pantry entry references when pantry entry is updated', async (t) => {
  const foodId = 'food-id-2';
  const foodName = 'chickpea';
  const pantryId = 'pantry-id-2';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-2';
  const foodReference = { id: foodId, name: foodName };
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [
      { foodReference, pantryEntryReference: { id: pantryId, sensitivity: 0 } },
      { foodReference: { id: 'food-id-0' } },
    ],
  });
  const symptomEntryId = 'symptom-entry-id-2';
  await diary.doc(symptomEntryId).set({ $: 'SymptomEntry' });

  // Add a pantry entry
  const sensitivity = 2;
  const pantryEntry = { id: pantryId, foodReference, sensitivity };
  const beforeSnap = fft.firestore.makeDocumentSnapshot(
    { foodReference, sensitivity: 0 },
    `user_data/${testUserId}/pantry/${pantryId}`
  );
  const afterSnap = fft.firestore.makeDocumentSnapshot(pantryEntry, `user_data/${testUserId}/pantry/${pantryId}`);
  const change = fft.makeChange(beforeSnap, afterSnap);

  const wrapped = fft.wrap(myFunctions.onPantryEntryUpdated);
  const context = { params: { userId: testUserId, pantryId: pantryId } };
  await wrapped(change, context);

  // Check that pantry entry reference has been updated
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference.sensitivity, sensitivity);
  t.is(mealEntry.mealElements[1].pantryEntryReference, undefined);
});

test('deletes pantry entry references when pantry entry is deleted', async (t) => {
  const foodId = 'food-id-3';
  const foodName = 'chickpea';
  const pantryId = 'pantry-id-3';
  const pantryId2 = 'pantry-id-4';

  // Create diary
  const diary = db.collection(`user_data/${testUserId}/diary`);
  const mealEntryId = 'meal-entry-id-3';
  const foodReference = { id: foodId, name: foodName };
  await diary.doc(mealEntryId).set({
    $: 'MealEntry',
    mealElements: [
      { foodReference, pantryEntryReference: { id: pantryId, sensitivity: 0 } },
      { foodReference: { id: 'food-id-0' } },
    ],
  });

  // Add a pantry entry
  const sensitivity = 2;
  const pantryEntry = { id: pantryId, foodReference, sensitivity };
  const snap = fft.firestore.makeDocumentSnapshot(pantryEntry, `user_data/${testUserId}/pantry/${pantryId}`);
  fft.firestore.makeDocumentSnapshot({ sensitivity: 0 }, `user_data/${testUserId}/pantry/${pantryId2}`);

  const wrapped = fft.wrap(myFunctions.onPantryEntryDeleted);
  const context = { params: { userId: testUserId, pantryId: pantryId } };
  await wrapped(snap, context);

  // Check that pantry entry reference has been deleted
  const mealEntrySnap = await diary.doc(mealEntryId).get();
  const mealEntry = mealEntrySnap.data();
  t.is(mealEntry.mealElements[0].pantryEntryReference, undefined);
});
