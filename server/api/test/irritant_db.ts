import path from 'path';
import test from 'ava';
import { Database, open } from 'sqlite';
import * as sqlite3 from 'sqlite3';
import { getIrritants, getIrritantData, getFoodGroups, selectCanonicalMap, extendIrritants } from '../src/resources/irritant_db';

sqlite3.verbose();

var db: Database;
interface Count { count: number; }

test.before(async () => {
  const dbPath = path.resolve(__dirname, '../data', 'irritants.sqlite3');
  db = await open({
    filename: dbPath,
    driver: sqlite3.cached.Database
  });
  await extendIrritants(db);
});

test.after.always(async () => {
  const cleanupSql = 'DROP TABLE IF EXISTS extended_irritant_content;';
  await db.exec(cleanupSql);
  if (db) {
    db.close();
  }
});

test('getIrritants', async t => {
  const irritants = await getIrritants(db);

  const sql = `
SELECT count(DISTINCT foods.food_id) as count
 FROM irritant_content
      INNER JOIN
      foods ON irritant_content.food_id = foods.food_id
WHERE foods.show_irritants;
`;
  const row = await db.get<Count>(sql);
  const foodCount = row.count;

  t.is(irritants.length, foodCount);

  const irritant = irritants[0];
  t.true('foodIds' in irritant);
  t.true('names' in irritant);
  t.true('irritants' in irritant);
});

test('getIrritantData', async t => {
  const irritantData = await getIrritantData(db);

  const sql = 'SELECT COUNT(*) AS count FROM irritants WHERE low_dose IS NOT NULL AND moderate_dose IS NOT NULL AND high_dose IS NOT NULL';
  const row = await db.get<Count>(sql);
  const irritantCount = row.count;

  t.is(irritantData.length, irritantCount);
});

test('getFoodGroups', async t => {
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
  const row = await db.get<Count>(sql);
  const foodCount = row.count;
  const foodGroups = await getFoodGroups(db);

  t.is(foodGroups.length, foodCount);

  // Ensure query did not alter table
  const row2 = await db.get(sql);
  const foodCount2 = row2.count;
  t.is(foodCount, foodCount2);
});

test('selectCanonicalMap', async t => {
  const sql = 'SELECT COUNT(*) AS count FROM foods WHERE canonical_name IS NOT NULL AND canonical_edamam_id IS NOT NULL';
  const row = await db.get<Count>(sql);
  const foodCount = row.count;

  const canonicals = await selectCanonicalMap(db);

  t.is(canonicals.size, foodCount);

  canonicals.forEach((food_reference, food_id) => {
    t.true(food_id !== null);
    t.true(food_reference.name !== null);
    t.true(food_reference.id !== null);
  });
});