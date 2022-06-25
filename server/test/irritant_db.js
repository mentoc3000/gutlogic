const path = require('path');
const test = require('ava');
const sqlite = require('sqlite');
const sqlite3 = require('sqlite3').verbose();

const irritant_db = require('../src/irritant_db');

var db;

test.before(async () => {
  const dbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');
  db = await sqlite.open({
    filename: dbPath,
    driver: sqlite3.cached.Database
  });
});

test.after.always(async () => {
  if (db) {
    db.close();
  }
});

test('getIrritants', async t => {
  const irritants = await irritant_db.getIrritants(db);

  const sql = `
SELECT count(DISTINCT foods.food_id) as count
 FROM irritant_content
      INNER JOIN
      foods ON irritant_content.food_id = foods.food_id
WHERE foods.show_irritants;
`;
  const row = await db.get(sql);
  const foodCount = row.count;

  t.is(irritants.length, foodCount);

  const irritant = irritants[0];
  t.true('foodIds' in irritant);
  t.true('names' in irritant);
  t.true('irritants' in irritant);
});

test('getIrritantData', async t => {
  const irritantData = await irritant_db.getIrritantData(db);

  const row = await db.get('SELECT COUNT(*) AS count FROM irritants WHERE low_dose IS NOT NULL AND moderate_dose IS NOT NULL AND high_dose IS NOT NULL');
  const irritantCount = row.count;

  t.is(irritantData.length, irritantCount);
});

test('getFoodGroups', async t => {
  const foodGroups = await irritant_db.getFoodGroups(db);

  const sql = `
SELECT COUNT(DISTINCT food_group_name) AS count
  FROM food_groups
  JOIN foods on foods.food_id = food_groups.food_id
 WHERE foods.searchable_in_edamam AND foods.show_irritants AND foods.show_in_browse;
`;
  const row = await db.get(sql);
  const groupCount = row.count;

  t.is(foodGroups.length, groupCount);

  foodGroups.forEach((foodGroup) => {
    t.true(foodGroup.foodRefs.length > 0);
  });
});

test('getFoodGroups2', async t => {
  const sql = `
SELECT COUNT(*) as count
  FROM food_groups AS fg
       JOIN
       foods AS f ON f.food_id = fg.food_id
 WHERE canonical_edamam_id IS NOT NULL AND 
       f.show_irritants AND 
       f.searchable_in_edamam AND
       f.show_in_browse;
`;
  const row = await db.get(sql);
  const foodCount = row.count;
  `S`;
  const foodGroups = await irritant_db.getFoodGroups2(db);

  t.is(foodGroups.length, foodCount);

  // Ensure query did not alter table
  const row2 = await db.get(sql);
  const foodCount2 = row2.count;
  t.is(foodCount, foodCount2);
});