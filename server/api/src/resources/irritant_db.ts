import path from "path";
import * as sqlite from "sqlite";
import * as sqlite3 from "sqlite3";
import { FoodReference } from "./food";
import log from "./logger";

export interface Irritant { name: string, concentration: number, dosePerServing: number; }
interface FoodInGroup { group: string, foodRef: FoodReference; doses: ReducedIrritantValues; }
interface FoodIrritants { foodIds: string[], names: string[], irritants: Irritant[], canonical: FoodReference; }
interface ReducedIrritantValues {
  Fructose?: number;
  Sorbitol?: number;
  Mannitol?: number;
  Lactose?: number;
  GOS?: number,
  Fructan?: number;
}
interface IrritantValues {
  Fructose?: number;
  Sorbitol?: number;
  Mannitol?: number;
  Lactose?: number;
  Raffinose?: number;
  Stachyose?: number;
  Nystose?: number;
  Kestose?: number;
  Fructan?: number;
}
interface FoodIrritantData { name: string, intensitySteps: number[]; }

class IrritantDb {
  readonly dbPath: string;
  private _db: sqlite.Database | null;

  constructor() {
    this.dbPath = path.resolve(__dirname, "../../data", "irritants.sqlite3");
    this._db = null;
  }

  async get(): Promise<sqlite.Database> {
    if (this._db === null) {
      log.d(`Opening irritant database from ${this.dbPath}`);
      this._db = await sqlite.open({
        filename: this.dbPath,
        driver: sqlite3.cached.Database
      });
    }
    return Promise.resolve(this._db);
  }

  async close(): Promise<void> {
    await this._db.close();
    this._db = null;
  }
}

const irritantDb = new IrritantDb();
export default irritantDb;

// Returns a new multi-map (each key is a list of values) using the key returned by the [keyfunc] function and the value returned by the [valfunc] function.
function multimap<T, S, R>(collection: T[], keyfunc: (arg0: T) => S, valfunc: (arg0: T) => R): Map<S, R[]> {
  const map = new Map<S, R[]>();

  for (const el of collection) {
    const key = keyfunc(el);
    const val = valfunc(el);
    if (val) {
      map.set(key, [...(map.get(key) ?? []), val]);
    }
  }

  return map;
}

const allConcentrations = `MAX(CASE WHEN ic.irritant_name = 'Excess Fructose' THEN ic.concentration ELSE NULL END) AS Fructose,
  MAX(CASE WHEN ic.irritant_name = 'Mannitol' THEN ic.concentration ELSE NULL END) AS Mannitol,
  MAX(CASE WHEN ic.irritant_name = 'Sorbitol' THEN ic.concentration ELSE NULL END) AS Sorbitol,
  MAX(CASE WHEN ic.irritant_name = 'Lactose' THEN ic.concentration ELSE NULL END) AS Lactose,
  MAX(CASE WHEN ic.irritant_name = 'Raffinose' THEN ic.concentration ELSE NULL END) AS Raffinose,
  MAX(CASE WHEN ic.irritant_name = 'Stachyose' THEN ic.concentration ELSE NULL END) AS Stachyose,
  MAX(CASE WHEN ic.irritant_name = 'Nystose' THEN ic.concentration ELSE NULL END) AS Nystose,
  MAX(CASE WHEN ic.irritant_name = 'Kestose' THEN ic.concentration ELSE NULL END) AS Kestose,
  MAX(CASE WHEN ic.irritant_name = 'Fructan' THEN ic.concentration ELSE NULL END) AS Fructan`;
const allDosePerServings = allConcentrations.split("\n").map((s) => "weight_per_serving * " + s).join("\n");

// Returns a new multi-map of edamam ID values keyed by food ID.
async function selectEdamamIdMap(db: sqlite.Database): Promise<Map<string, string[]>> {
  const sql = "SELECT food_id, edamam_id FROM edamam";
  interface Row { food_id: string, edamam_id: string; }

  const keyfunc = (row: Row) => row.food_id;
  const valfunc = (row: Row) => row.edamam_id;

  return multimap(await db.all<Row[]>(sql), keyfunc, valfunc);
}

// Returns a new multi-map of food name values keyed by food ID.
async function selectFoodNameMap(db: sqlite.Database) {
  const sql = `
SELECT food_id,
       canonical_name
  FROM foods
 WHERE canonical_name IS NOT NULL;
`;
  interface Row { food_id: string, canonical_name: string; }

  const keyfunc = (row: Row) => row.food_id;
  const valfunc = (row: Row) => row.canonical_name;

  return multimap(await db.all(sql), keyfunc, valfunc);
}

// Returns a new multi-map of canonical edamam food references keyed by food ID.
export async function selectCanonicalMap(db: sqlite.Database): Promise<Map<string, FoodReference>> {
  const sql = `SELECT food_id, canonical_name, canonical_edamam_id FROM foods
               WHERE canonical_name IS NOT NULL AND canonical_edamam_id IS NOT NULL`;
  interface Row { food_id: string, canonical_name: string, canonical_edamam_id: string; }

  const rows = await db.all<Row[]>(sql);
  const map = new Map<string, FoodReference>();

  for (const row of rows) {
    const canonical = { $: "EdamamFoodReference", id: row.canonical_edamam_id, name: row.canonical_name };
    map.set(row.food_id, canonical);
  }

  return map;
}

// Returns a new multi-map of { name, concentration, dosePerServing } values keyed by food ID.
async function selectIrritantMap(db: sqlite.Database): Promise<Map<string, Irritant[]>> {
  const sql = `
SELECT foods.food_id AS food_id,
       display_name AS irritant,
       MAX(concentration) AS concentration,
       foods.weight_per_serving AS weight_per_serving
  FROM extended_irritant_content
       INNER JOIN
       foods ON extended_irritant_content.food_id = foods.food_id
       JOIN
       irritants ON extended_irritant_content.irritant_name = irritants.irritant_name
 WHERE foods.show_irritants AND 
       extended_irritant_content.irritant_name != 'Fructose' AND 
       extended_irritant_content.irritant_name != 'Glucose'
 GROUP BY extended_irritant_content.food_id,
          irritant;
`;
  interface Row { food_id: string, irritant: string, concentration: number, weight_per_serving: number; }

  const keyfunc = (row: Row) => row.food_id;
  const valfunc = (row: Row) => ({ name: row.irritant, concentration: row.concentration, dosePerServing: row.concentration * row.weight_per_serving });

  return multimap(await db.all<Row[]>(sql), keyfunc, valfunc);
}

/// Return the irritant with the maximum concentration with name matching [name].
/// If no elements match [name], return null.
function maxConIrritant(irritants: Irritant[], name: string): Irritant {
  return irritants
    .filter((el) => el.name === name)
    .reduce((acc, el) => acc === null || el.concentration > acc.concentration ? el : acc, null);
}

function processIrritants(irritants: Irritant[]) {
  const processedIrritants: Irritant[] = [];

  // Excess fructose
  // TODO: maxConIrritant may not be necessary because MAX is calculated in sql query
  const fructose = maxConIrritant(irritants, "Fructose");
  if (fructose !== null) {
    processedIrritants.push(fructose);
  }

  // Disaccharides
  const sorbitol = maxConIrritant(irritants, "Sorbitol");
  if (sorbitol !== null) {
    processedIrritants.push(sorbitol);
  }

  const mannitol = maxConIrritant(irritants, "Mannitol");
  if (mannitol !== null) {
    processedIrritants.push(mannitol);
  }

  const lactose = maxConIrritant(irritants, "Lactose");
  if (lactose !== null) {
    processedIrritants.push(lactose);
  }

  // Galacto-oligosaccharides (GOS)
  // Raffinose and stachyose are the two GOS irritants for which we have data. GOS is the
  // sum of these two, if at least one has data.
  const raffinose = maxConIrritant(irritants, "Raffinose");
  const stachyose = maxConIrritant(irritants, "Stachyose");
  if (raffinose !== null || stachyose !== null) {
    processedIrritants.push({
      name: "GOS",
      concentration: raffinose.concentration + stachyose.concentration,
      dosePerServing: raffinose.dosePerServing + stachyose.dosePerServing,
    });
  }

  // Fructo-oligosaccharides (fructan)
  // Kestose and nystose are two fructans for which we have data, but we also have
  // total fructan. Use fructan if it is larger than the sum of the two individuals.
  const nystose = maxConIrritant(irritants, "Nystose");
  const kestose = maxConIrritant(irritants, "Kestose");
  const totalFructan = maxConIrritant(irritants, "Fructan");

  const concentrationNystose = nystose !== null ? nystose.concentration : null;
  const concentrationKestose = kestose !== null ? kestose.concentration : null;
  const concentrationTotalFructan = totalFructan !== null ? totalFructan.concentration : null;

  if (totalFructan === null && nystose === null && kestose === null) {
    // pass
  } else if (totalFructan === null || concentrationTotalFructan < concentrationNystose + concentrationKestose) {
    processedIrritants.push({
      name: "Fructan",
      concentration: nystose.concentration + kestose.concentration,
      dosePerServing: nystose.dosePerServing + kestose.dosePerServing,
    });
  } else {
    processedIrritants.push(totalFructan);
  }

  return processedIrritants;
}

export async function elementaryFoods(db: sqlite.Database): Promise<FoodIrritants[]> {
  // TODO: cache result
  const edamamIdMap = await selectEdamamIdMap(db);
  const irritantMap = await selectIrritantMap(db);
  const foodNameMap = await selectFoodNameMap(db);
  const canonicalMap = await selectCanonicalMap(db);

  function createIrritantEntry(id: string) {
    const names = foodNameMap.get(id) ?? [];
    const foodIds = edamamIdMap.get(id) ?? [];
    const irritants = irritantMap.get(id) ?? [];
    const canonical = canonicalMap.get(id) ?? null;
    return { foodIds, names, irritants: processIrritants(irritants), canonical };
  }

  // combine the edamam/irritant/name multi-maps into a list of { foodIds, names, irritants } objects
  return Array.from(irritantMap.keys()).map(createIrritantEntry);
}

/// Create an object with irritant name properties and dose per serving values
function reduceIrritants(irritants: IrritantValues): ReducedIrritantValues {
  const processedIrritants: ReducedIrritantValues = {};

  ["Fructose", "Sorbitol", "Mannitol", "Lactose"].forEach((i) => {
    if (i in irritants && irritants[i] !== null) {
      processedIrritants[i] = Math.max(irritants[i], 0);
    }
  });

  // Galacto-oligosaccharides (GOS)
  // Raffinose and stachyose are the two GOS irritants for which we have data. GOS is the
  // sum of these two, if at least one has data.
  if ("Raffinose" in irritants || "Stachyose" in irritants) {
    const gos = irritants.Raffinose + irritants.Stachyose;
    if (gos !== null) {
      processedIrritants.GOS = gos;
    }
  }

  // Fructo-oligosaccharides (fructan)
  // Kestose and nystose are two fructans for which we have data, but we also have
  // total fructan. Use fructan if it is larger than the sum of the two individuals.
  var totalFructan = null;
  if ("Fructan" in irritants) {
    totalFructan = irritants.Fructan;
  }

  var sumFructan = null;
  if ("Kestose" in irritants) {
    sumFructan += irritants.Kestose;
  }
  if ("Nystose" in irritants) {
    sumFructan += irritants.Nystose;
  }

  const fructan = totalFructan > sumFructan ? totalFructan : sumFructan;
  if (fructan !== null) {
    processedIrritants.Fructan = fructan;
  }

  return processedIrritants;
}

/// Food groups data
export async function foodsInGroups(db: sqlite.Database): Promise<FoodInGroup[]> {
  // TODO: cache result
  const selectSql = `
SELECT food_group_name,
       canonical_name,
       canonical_edamam_id,`
    + allDosePerServings + `
  FROM food_groups AS fg
       JOIN
       foods AS f ON f.food_id = fg.food_id
       LEFT OUTER JOIN
       extended_irritant_content AS ic ON fg.food_id = ic.food_id
 WHERE canonical_edamam_id IS NOT NULL AND 
       f.show_irritants AND 
       f.searchable_in_edamam AND
       f.show_in_browse
 GROUP BY ic.food_id,
          food_group_name,
          canonical_name
 ORDER BY canonical_name;
 `;
  interface Row extends IrritantValues { food_group_name: string, canonical_edamam_id: string, canonical_name: string; }

  const rows: Row[] = await db.all(selectSql);
  const toFoodRef = (row: Row) => ({ "$": "EdamamFoodReference", "id": row.canonical_edamam_id, "name": row.canonical_name });

  return rows.map(row => ({ group: row.food_group_name, foodRef: toFoodRef(row), doses: reduceIrritants(row) }));
}

export async function irritantThresholds(db: sqlite.Database): Promise<FoodIrritantData[]> {
  // TODO: cache result
  const sql = `SELECT display_name,
                      low_dose,
                      moderate_dose,
                      high_dose
                 FROM irritants
                WHERE low_dose IS NOT NULL AND 
                      moderate_dose IS NOT NULL AND 
                      high_dose IS NOT NULL;
                  `;
  interface Row { display_name: string, low_dose: number, moderate_dose: number, high_dose: number; }

  const rows = await db.all<Row[]>(sql);
  const data: { name: string, intensitySteps: number[]; }[] = [];

  for (const row of rows) {
    const name = row.display_name;
    const intensitySteps = [row.low_dose, row.moderate_dose, row.high_dose];
    data.push({ name, intensitySteps });
  }

  return data;
}

export async function irritantsInFoodId(db: sqlite.Database, foodId: string): Promise<Irritant[] | null> {
  // TODO: cache result
  const selectSql = `
SELECT weight_per_serving,`
    + allConcentrations + `
  FROM edamam
       JOIN
       foods ON foods.food_id = edamam.food_id
       LEFT OUTER JOIN
       extended_irritant_content AS ic ON edamam.food_id = ic.food_id
 WHERE edamam.edamam_id = ?
 GROUP BY ic.food_id;`;

  interface Row extends IrritantValues { weight_per_serving: number; }
  const row: Row = await db.get(selectSql, foodId);

  if (!row) return null;

  const weightPerServing = row.weight_per_serving;
  const reducedIrritantConcentrations = reduceIrritants(row);

  const irritants: Irritant[] = [];
  for (let name in reducedIrritantConcentrations) {
    const concentration = reducedIrritantConcentrations[name];
    irritants.push({ name, concentration, dosePerServing: concentration * weightPerServing });
  }
  return irritants;
}

export async function foodRef(db: sqlite.Database, name: string): Promise<FoodReference | null> {
  const selectSql = `
  SELECT canonical_edamam_id
  FROM food_names
  JOIN foods on food_names.food_id = foods.food_id
  WHERE food_names.food_name = ?
  COLLATE NOCASE;`;

  const row: { canonical_edamam_id: string; } = await db.get(selectSql, name);

  if (!row || row.canonical_edamam_id === null) return null;

  return { $: "EdamamFoodReference", name, id: row.canonical_edamam_id };
}

/// Return true if ingredients are shown for this food
export async function showIngredients(db: sqlite.Database, foodContentsLabel: string, edamamId: string): Promise<Boolean> {
  if (!foodContentsLabel) return false;

  const selectSql = `
  SELECT show_ingredients
  FROM edamam
  WHERE edamam_id = ?;`;

  const row: { show_ingredients: number; } = await db.get(selectSql, edamamId);

  if (row) {
    // Hide ingredients if show_ingredients column is not true for elementary food
    return row.show_ingredients === 1;
  } else {
    // By default, show ingredients
    return true;
  }
}