#!/usr/bin/env node

const tools = require('firebase-tools');
const { initializeApp, applicationDefault, cert } = require('firebase-admin/lib/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/lib/firestore');

const foodIrritantData = require('../data/irritants.json');

const maxBatchSize = 500;

initializeApp({
  credential: applicationDefault(),
});

const db = getFirestore();
const foodIrritantsCollection = db.collection('food_irritants');

async function deleteCollection(collectionRef, batchSize) {
  const query = collectionRef.orderBy('name').limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;
  if (batchSize === 0) {
    // When there are no documents left, we are done
    resolve();
    return;
  }

  // Delete documents in a batch
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  // Recurse on the next process tick, to avoid
  // exploding the stack.
  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

async function addData(collectionRef, data) {
  const dataSubset = data.slice(0, maxBatchSize);
  if (dataSubset.length === 0) {
    return;
  }

  const batch = db.batch();
  dataSubset.forEach((entry) => {
    const newRef = collectionRef.doc();
    batch.set(newRef, entry);
  });
  await batch.commit();

  process.nextTick(() => {
    addData(collectionRef, data.slice(maxBatchSize));
  });
}

(async () => {
  // Delete old data
  await deleteCollection(foodIrritantsCollection, maxBatchSize);

  // Add new data
  await addData(foodIrritantsCollection, foodIrritantData);
})();
