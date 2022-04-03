#!/usr/bin/env node

const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const tools = require('firebase-tools');
const admin = require('firebase-admin');

const foodIrritantDbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');

const maxBatchSize = 500;

admin.initializeApp();

const db = admin.firestore();
const foodIrritantsCollection = db.collection('food_irritants');
const foodGroupsCollection = db.collection('food_groups');

async function selectEdamamIdMap(db) {
  return new Promise((resolve, reject) => {
    // TODO: could be more efficient with GROUP_CONCAT followed by splitting on comma
    const sql = `SELECT food_id, edamam_id FROM edamam`;
    db.all(sql, [], (err, rows) => {
      if (err) {
        reject(err);
      }
      const data = new Map();
      for (const row of rows) {
        const foodId = row.food_id;
        const edamamId = row.edamam_id;
        let edamamIds = data.get(foodId);
        if (edamamIds === undefined) {
          edamamIds = [];
        }
        edamamIds.push(edamamId);
        data.set(foodId, edamamIds);
      }
      resolve(data);
    });
  });
}
async function selectFoodNameMap(db) {
  return new Promise((resolve, reject) => {
    const sql = `SELECT food_id, food_name FROM food_names`;
    db.all(sql, [], (err, rows) => {
      if (err) {
        reject(err);
      }
      const data = new Map();
      for (const row of rows) {
        const foodId = row.food_id;
        const foodName = row.food_name;
        let foodNames = data.get(foodId);
        if (foodNames === undefined) {
          foodNames = [];
        }
        foodNames.push(foodName);
        data.set(foodId, foodNames);
      }
      resolve(data);
    });
  });
}

async function selectIrritantMap(db) {
  return new Promise((resolve, reject) => {
    // TODO: get max of each irritant
    const sql = `
SELECT
    foods.food_id as food_id,
    irritant_name as irritant,
    MAX(concentration) as concentration,
    foods.weight_per_serving as weight_per_serving
FROM
    irritant_content
INNER JOIN foods ON irritant_content.food_id = foods.food_id
GROUP BY irritant_content.food_id, irritant`;
    db.all(sql, [], (err, rows) => {
      if (err) {
        reject(err);
      }
      const data = new Map();
      for (const row of rows) {
        const foodId = row.food_id;
        const name = row.irritant;
        const concentration = row.concentration;
        const weightPerServing = row.weight_per_serving;
        const dosePerServing = concentration * weightPerServing;
        const irritant = { concentration, dosePerServing, name };
        let irritants = data.get(foodId);
        if (irritants === undefined) {
          irritants = [];
        }
        irritants.push(irritant);
        data.set(foodId, irritants);
      }
      resolve(data);
    });
  });
}

async function getIrritants(db) {
  const edamamIdMap = await selectEdamamIdMap(db);
  const irritantMap = await selectIrritantMap(db);
  const foodNameMap = await selectFoodNameMap(db);

  const data = [];
  for (const foodId of irritantMap.keys()) {
    let edamamIds = edamamIdMap.get(foodId);
    if (edamamIds === undefined) {
      edamamIds = [];
    }

    let irritants = irritantMap.get(foodId);
    if (irritants === undefined) {
      irritants = [];
    }

    let names = foodNameMap.get(foodId);
    if (names === undefined) {
      names = [];
    }

    const datum = { foodIds: edamamIds, irritants, names };
    data.push(datum);
  }

  return data;
}

async function getFoodGroups(db) {
  return new Promise((resolve, reject) => {
    const sql = 'SELECT * FROM food_groups';
    db.all(sql, [], (err, rows) => {
      if (err) {
        reject(err);
      }
      const group_names = new Set(rows.map((row) => row.food_group_name));
      const data = [];
      for (const row of rows) {
        const foodGroupName = row.food_group_name;
        const edamamId = row.edamam_id;
        const foodName = row.food_name;
        let foodGroup = data.find((e) => e['name'] === foodGroupName);
        if (foodGroup === undefined) {
          foodGroup = { name: foodGroupName, foodRefs: [] };
          data.push(foodGroup);
        }
        const entry = { $: 'EdamamFoodReference', id: edamamId, name: foodName };
        foodGroup['foodRefs'].push(entry);
      }
      resolve(data);
    });
  });
}

async function deleteCollection(collectionRef, batchSize) {
  const query = collectionRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(firestore, query, resolve).catch(reject);
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

  const batch = firestore.batch();
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
  const db = new sqlite3.Database(foodIrritantDbPath, sqlite3.OPEN_READONLY);
  const foodIrritantData = await getIrritants(db);
  const foodGroupsData = await getFoodGroups(db);
  db.close();

  // Delete old data
  await deleteCollection(foodIrritantsCollection, maxBatchSize);
  await deleteCollection(foodGroupsCollection, maxBatchSize);

  // Add new data
  await addData(foodIrritantsCollection, foodIrritantData);
  await addData(foodGroupsCollection, foodGroupsData);
})();
