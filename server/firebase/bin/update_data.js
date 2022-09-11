#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const sqlite = require('sqlite');
const sqlite3 = require('sqlite3').verbose();
const { replaceFirestoreCollection } = require('../src/firebase_collection');
const { getIrritants, getFoodGroups, getFoodGroups2, getIrritantData } = require('../src/irritant_db');

(async () => {
  const dbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');

  console.log(`Opening irritant database at ${dbPath}`);

  const db = await sqlite.open({
    filename: dbPath,
    driver: sqlite3.cached.Database
  });

  const certPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const certData = JSON.parse(fs.readFileSync(certPath));
  const certProject = certData['project_id'];

  console.log(`Initializing Firebase project ${certProject} using credentials from ${certPath}`);

  admin.initializeApp();

  const firestore = admin.firestore();
  const writer = firestore.bulkWriter();

  await replaceFirestoreCollection(writer, firestore.collection('food_irritants'), await getIrritants(db));
  await replaceFirestoreCollection(writer, firestore.collection('food_groups'), await getFoodGroups(db));
  await replaceFirestoreCollection(writer, firestore.collection('food_groups2'), await getFoodGroups2(db));
  await replaceFirestoreCollection(writer, firestore.collection('irritant_data'), await getIrritantData(db));
  await writer.close();
  await db.close();
})();
