#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const sqlite = require('sqlite');
const sqlite3 = require('sqlite3').verbose();

// Returns a new multi-map (each key is a list of values) using the key returned by the [keyfunc] function and the value returned by the [valfunc] function.
function multimap(collection, keyfunc, valfunc) {
  const map = new Map();

  for (const el of collection) {
    const key = keyfunc(el);
    const val = valfunc(el);
    map.set(key, [...(map.get(key) ?? []), val]);
  }

  return map;
}

// Returns a new multi-map of edamam ID values keyed by food ID.
async function selectEdamamIdMap(db) {
  const sql = `SELECT food_id, edamam_id FROM edamam`;

  const keyfunc = (row) => row.food_id;
  const valfunc = (row) => row.edamam_id;

  return multimap(await db.all(sql), keyfunc, valfunc);
}

// Returns a new multi-map of food name values keyed by food ID.
async function selectFoodNameMap(db) {
  const sql = `SELECT food_id, food_name FROM food_names`;

  const keyfunc = (row) => row.food_id;
  const valfunc = (row) => row.food_name;

  return multimap(await db.all(sql), keyfunc, valfunc);
}

/// Returns a new multi-map of { name, concentration, dosePerServing } values keyed by food ID.
async function selectIrritantMap(db) {
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

  const keyfunc = (row) => row.food_id;
  const valfunc = (row) => ({ name: row.irritant, concentration: row.concentration, dosePerServing: row.concentration * row.weight_per_serving });

  return multimap(await db.all(sql), keyfunc, valfunc);
}

/// Return the irritant with the maximum concentration with name matching [name].
/// If no elements match [name], return null.
function maxConIrritant(irritants, name) {
  return irritants
    .filter((el) => el.name === name)
    .reduce((acc, el) => acc === null || el.concentration > acc.concentration ? el : acc, null);
}

function processIrritants(irritants) {
  const processedIrritants = [];

  // Excess fructose
  const fructose = maxConIrritant(irritants, 'Fructose');
  const glucose = maxConIrritant(irritants, 'Glucose');
  if (fructose !== null && glucose !== null) {
    processedIrritants.push({
      name: 'Fructose',
      concentration: Math.max(fructose.concentration - glucose.concentration, 0),
      dosePerServing: Math.max(fructose.dosePerServing - glucose.dosePerServing, 0),
    });
  }

  // Disaccharides
  const sorbitol = maxConIrritant(irritants, 'Sorbitol');
  if (sorbitol !== null) {
    processedIrritants.push(sorbitol);
  }

  const mannitol = maxConIrritant(irritants, 'Mannitol');
  if (mannitol !== null) {
    processedIrritants.push(mannitol);
  }

  const lactose = maxConIrritant(irritants, 'Lactose');
  if (lactose !== null) {
    processedIrritants.push(lactose);
  }

  // Galacto-oligosaccharides (GOS)
  // Raffinose and stachyose are the two GOS irritants for which we have data. GOS is the
  // sum of these two, if at least one has data.
  const raffinose = maxConIrritant(irritants, 'Raffinose');
  const stachyose = maxConIrritant(irritants, 'Stachyose');
  if (raffinose !== null || stachyose !== null) {
    processedIrritants.push({
      name: 'GOS',
      concentration: raffinose.concentration + stachyose.concentration,
      dosePerServing: raffinose.dosePerServing + stachyose.dosePerServing,
    });
  }

  // Fructo-oligosaccharides (fructan)
  // Kestose and nystose are two fructans for which we have data, but we also have
  // total fructan. Use fructan if it is larger than the sum of the two individuals.
  const nystose = maxConIrritant(irritants, 'Nystose');
  const kestose = maxConIrritant(irritants, 'Kestose');
  const totalFructan = maxConIrritant(irritants, 'Fructan');

  const concentrationNystose = nystose !== null ? nystose.concentration : null;
  const concentrationKestose = kestose !== null ? kestose.concentration : null;
  const concentrationTotalFructan = totalFructan !== null ? totalFructan.concentration : null;

  if (totalFructan === null && nystose === null && kestose === null) {
    // pass
  } else if (totalFructan === null || concentrationTotalFructan < concentrationNystose + concentrationKestose) {
    processedIrritants.push({
      name: 'Fructan',
      concentration: nystose.concentration + kestose.concentration,
      dosePerServing: nystose.dosePerServing + kestose.dosePerServing,
    });
  } else {
    processedIrritants.push(totalFructan);
  }

  return processedIrritants;
}

async function getIrritants(db) {
  const edamamIdMap = await selectEdamamIdMap(db);
  const irritantMap = await selectIrritantMap(db);
  const foodNameMap = await selectFoodNameMap(db);

  function createIrritantEntry(id) {
    const names = foodNameMap.get(id) ?? [];
    const foodIds = edamamIdMap.get(id) ?? [];
    const irritants = irritantMap.get(id) ?? [];
    return { foodIds, names, irritants: processIrritants(irritants) };
  }

  // combine the edamam/irritant/name multi-maps into a list of { foodIds, names, irritants } objects
  return Array.from(irritantMap.keys()).map(createIrritantEntry);
}

/// Food Groups data, version 1
async function getFoodGroups(db) {
  const sql = 'SELECT * FROM food_groups';

  const keyfunc = (row) => row.food_group_name;
  const valfunc = (row) => ({ $: 'EdamamFoodReference', id: row.edamam_id, name: row.food_name });

  const groups = multimap(await db.all(sql), keyfunc, valfunc);

  // flatten the food reference multi-map into a list of { name, foodRefs } objects
  return Array.from(groups.entries()).map(entry => ({ name: entry[0], foodRefs: entry[1] }));
}

/// Create an object with irritant name properties and dose per serving values
function processIrritantDoses(irritants) {
  const processedIrritants = {};

  const simpleIrritantNames = ['Fructose', 'Sorbitol', 'Mannitol', 'Lactose'];
  simpleIrritantNames.forEach((i) => {
    if (i in irritants && irritants[i] !== null) {
      processedIrritants[i] = irritants[i];
    }
  });

  // Galacto-oligosaccharides (GOS)
  // Raffinose and stachyose are the two GOS irritants for which we have data. GOS is the
  // sum of these two, if at least one has data.
  if ('Raffinose' in irritants || 'Stachyose' in irritants) {
    const gos = irritants.Raffinose + irritants.Stachyose;
    if (gos !== null) {
      processedIrritants['GOS'] = gos;
    }
  }

  // Fructo-oligosaccharides (fructan)
  // Kestose and nystose are two fructans for which we have data, but we also have
  // total fructan. Use fructan if it is larger than the sum of the two individuals.
  var totalFructan = null;
  if ('Fructan' in irritants) {
    totalFructan = irritants.Fructan;
  }

  var sumFructan = null;
  if ('Kestose' in irritants) {
    sumFructan += irritants.Kestose;
  }
  if ('Nystose' in irritants) {
    sumFructan += irritants.Nystose;
  }

  const fructan = totalFructan > sumFructan ? totalFructan : sumFructan;
  if (fructan !== null) {
    processedIrritants['Fructan'] = fructan;
  }

  return processedIrritants;
}

/// Food Groups data, version 2
async function getFoodGroups2(db) {
  const sql = `
SELECT food_group_name,
       e.edamam_id as edamam_id,
       food_name,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Excess Fructose' THEN ic.concentration ELSE NULL END) AS Fructose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Mannitol' THEN ic.concentration ELSE NULL END) AS Mannitol,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Sorbitol' THEN ic.concentration ELSE NULL END) AS Sorbitol,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Lactose' THEN ic.concentration ELSE NULL END) AS Lactose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Raffinose' THEN ic.concentration ELSE NULL END) AS Raffinose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Stachyose' THEN ic.concentration ELSE NULL END) AS Stachyose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Nystose' THEN ic.concentration ELSE NULL END) AS Nystose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Kestose' THEN ic.concentration ELSE NULL END) AS Kestose,
       weight_per_serving * MAX(CASE WHEN ic.irritant_name = 'Fructan' THEN ic.concentration ELSE NULL END) AS Fructan
  FROM food_groups AS fg
       LEFT OUTER JOIN
       edamam AS e ON fg.edamam_id = e.edamam_id
       LEFT OUTER JOIN
       irritant_content AS ic ON e.food_id = ic.food_id
       JOIN
       foods AS f ON f.food_id = ic.food_id
 GROUP BY ic.food_id;
`;

  const toFoodRef = (row) => ({ '$': 'EdamamFoodReference', 'id': row.edamam_id, 'name': row.food_name });

  const rows = await db.all(sql);

  return rows.map(row => ({ group: row.food_group_name, foodRef: toFoodRef(row), doses: processIrritantDoses(row) }));
}

// Replace all of the documents in the Firestore [collection] with the entries in the [data] array using the provided BulkWriter [writer].
async function replaceFirestoreCollection(writer, collection, data) {
  for (const doc of await collection.listDocuments()) {
    writer.delete(doc);
  }

  for (const entry of data) {
    writer.create(collection.doc(), entry);
  }
}

async function getIrritantData(db) {
  const sql = `SELECT display_name,
                      moderate_dose,
                      high_dose
                 FROM irritants
                WHERE moderate_dose IS NOT NULL AND 
                      high_dose IS NOT NULL;
                  `;
  const rows = await db.all(sql);
  const data = [];
  for (const row of rows) {
    const name = row.display_name.toLowerCase();
    const intensitySteps = [row.moderate_dose, row.high_dose];
    data.push({ name, intensitySteps });
  }
  return data;
}

(async () => {
  const dbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');

  console.log(`Opening irritant database at ${dbPath}`);

  const db = await sqlite.open({
    filename: dbPath,
    driver: sqlite3.cached.Database,
    mode: sqlite3.OPEN_READONLY
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
