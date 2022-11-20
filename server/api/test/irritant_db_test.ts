import path from "path";
import test from "ava";
import { Database, open } from "sqlite";
import * as sqlite3 from "sqlite3";
import * as idb from "../src/resources/irritant_db";

sqlite3.verbose();

var db: Database;
interface Count { count: number; }

test.before(async () => {
  const dbPath = path.resolve(__dirname, "../data", "irritants.sqlite3");
  db = await open({
    filename: dbPath,
    driver: sqlite3.cached.Database
  });
});

test.after.always(async () => {
  if (db) {
    db.close();
  }
});

test("elementaryFoods", async t => {
  const irritants = await idb.elementaryFoods(db);

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
  t.true("foodIds" in irritant);
  t.true("names" in irritant);
  t.true("irritants" in irritant);
});

test("irritantThresholds", async t => {
  const irritantData = await idb.irritantThresholds(db);

  const sql = "SELECT COUNT(*) AS count FROM irritants WHERE low_dose IS NOT NULL AND moderate_dose IS NOT NULL AND high_dose IS NOT NULL";
  const row = await db.get<Count>(sql);
  const irritantCount = row.count;

  t.is(irritantData.length, irritantCount);
});

test("foodsInGroups", async t => {
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
  const foodGroups = await idb.foodsInGroups(db);

  t.is(foodGroups.length, foodCount);

  // Ensure query did not alter table
  const row2 = await db.get(sql);
  const foodCount2 = row2.count;
  t.is(foodCount, foodCount2);
});

test("selectCanonicalMap", async t => {
  const sql = "SELECT COUNT(*) AS count FROM foods WHERE canonical_name IS NOT NULL AND canonical_edamam_id IS NOT NULL";
  const row = await db.get<Count>(sql);
  const foodCount = row.count;

  const canonicals = await idb.selectCanonicalMap(db);

  t.is(canonicals.size, foodCount);

  canonicals.forEach((food_reference, food_id) => {
    t.true(food_id !== null);
    t.true(food_reference.name !== null);
    t.true(food_reference.id !== null);
  });
});

test("irritantsInFoodId", async t => {
  const foodId = "food_b4m99bgatuhmfybeq0d7xa9uvr1b";
  const irritants = await idb.irritantsInFoodId(db, foodId);

  const fructose = irritants.filter((i) => i.name === "Fructose")[0];
  const mannitol = irritants.filter((i) => i.name === "Mannitol")[0];
  const lactose = irritants.filter((i) => i.name === "Lactose");

  t.is(fructose.name, "Fructose");
  t.is(fructose.dosePerServing, 6.072);
  t.is(mannitol.name, "Mannitol");
  t.is(mannitol.dosePerServing, 0);
  t.is(lactose.length, 0);
});

test("irritantsInFoodId with missing entry", async t => {
  const foodId = "12345";
  const irritants = await idb.irritantsInFoodId(db, foodId);

  t.is(irritants, null);
});

test("foodRef", async t => {
  const name = "Cheese, American";
  const food = await idb.foodRef(db, name);

  t.is(food.id, "food_bx7gq25bfsov27b76zqp2bhlkn1l");
});


test("foodRef name match is case insensitive", async t => {
  const name = "Cheese, american";
  const food = await idb.foodRef(db, name);

  t.is(food.id, "food_bx7gq25bfsov27b76zqp2bhlkn1l");
  t.is(food.name, name);
});
