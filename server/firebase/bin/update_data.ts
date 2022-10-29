#!/usr/bin/env node

import { readFileSync } from 'fs';
import path from 'path';
import admin from 'firebase-admin';
import * as sqlite from 'sqlite';
import * as sqlite3 from 'sqlite3';

sqlite3.verbose();

import { replaceFirestoreCollection } from '../src/firebase_collection';
import { getIrritants, getFoodGroups, getFoodGroups2, getIrritantData } from '../src/irritant_db';

(async () => {
  const dbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');

  console.log(`Opening irritant database at ${dbPath}`);

  const db = await sqlite.open({
    filename: dbPath,
    driver: sqlite3.cached.Database
  });

  const certPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const certData = JSON.parse(readFileSync(certPath, { encoding: 'utf8' }));
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
