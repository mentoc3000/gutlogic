import express, { Request, Response } from "express";
import edamam, { EdamamFoodMeasures, EdamamMeasure } from "../edamam/edamam";
import parseIngredients, { Ingredient } from "./ingredients";
import irritantDb, { irritantsInFoodId, Irritant, showIngredients } from "./irritant_db";
import log from "./logger";

export type Measure = {
  unit: string;
  weight: number;
};

export type Food = {
  id: string;
  name: string;
  brand: string | null;
  measures: Measure[];
  irritants?: Irritant[];
  ingredients?: Ingredient[];
};

export interface FoodReference { $: string, id: string, name: string; }

function isValidLabel(label: string | null): boolean {
  return label !== null && label !== "";
}

function isValidWeight(weight: number | null): boolean {
  return weight !== null && weight > 0;
}

/// Convert measures from Edamam into Gut Logic measures
function toMeasures(edamamMeasure: EdamamMeasure): Measure[] {
  var measures: Measure[] = [];

  if (
    isValidLabel(edamamMeasure.label) && isValidWeight(edamamMeasure.weight)
  ) {
    measures.push({
      unit: edamamMeasure.label!,
      weight: edamamMeasure.weight!,
    });
  }

  if (edamamMeasure.qualified) {
    for (var qualifiedMeasure of edamamMeasure.qualified) {
      if (qualifiedMeasure.qualifiers !== null) {
        for (var qualifier of qualifiedMeasure.qualifiers) {
          if (
            isValidWeight(qualifiedMeasure.weight)
          ) {
            const unit = isValidLabel(qualifier.label)
              ? `${edamamMeasure.label}, ${qualifier.label}`
              : edamamMeasure.label!;
            measures.push({
              unit: unit,
              weight: qualifiedMeasure.weight!,
            });
          }
        }
      }
    }
  }

  return measures;
}

/// Convert Edamam Food to Gut Logic Food
async function toFood(edamamFoodMeasures: EdamamFoodMeasures): Promise<Food | null> {
  if (!(edamamFoodMeasures?.food?.foodId)) return null;
  if (!(edamamFoodMeasures?.food?.label)) return null;

  const measures = edamamFoodMeasures?.measures?.map(toMeasures).reduce(
    (acc, el) => acc.concat(el),
    [],
  ) ?? [];
  const db = await irritantDb.get();
  const irritants = await irritantsInFoodId(db, edamamFoodMeasures.food.foodId);
  const foodContentsLabel = edamamFoodMeasures.food.foodContentsLabel;
  const ingredients = await showIngredients(db, foodContentsLabel, edamamFoodMeasures.food.foodId)
    ? await parseIngredients(foodContentsLabel) : null;

  return {
    id: edamamFoodMeasures.food.foodId,
    name: edamamFoodMeasures.food.label,
    brand: edamamFoodMeasures.food.brand,
    measures,
    irritants,
    ingredients,
  };
}

async function get(
  req: Request<{ foodID: string; }, unknown, unknown, { name: string; }>,
  res: Response,
) {
  const name = req.query.name;

  const foodID = req.params.foodID;
  const result = await edamam.get({ foodId: foodID, label: name });

  if (result.ok) {
    const food = await toFood(result.value);
    res.json({ data: food });
  } else {
    res.status(404).end();
  }
}

async function search(
  req: Request<unknown, unknown, unknown, { name: string; }>,
  res: Response,
) {
  const name = req.query.name;

  if (name === null) {
    res.status(400).end();
    return;
  }

  const result = await edamam.search({ name: name });

  if (result.ok) {
    const foods = await Promise.all(result.value.map(toFood));
    res.json({ data: foods });
  } else {
    res.json({ data: [] });
  }
}

async function upc(
  req: Request<{ upc: string; }, unknown, unknown, { name: string; }>,
  res: Response,
) {
  const barcode = req.params.upc;
  const result = await edamam.upc(barcode);

  if (result.ok) {
    const food = await toFood(result.value);
    res.json({ data: food });
  } else {
    res.status(404).end();
  }
}


const router = express.Router();

router.get("/v0/search", search);
router.get("/v0/:foodID", get);
router.get("/v0/upc/:upc", upc);

export default router;