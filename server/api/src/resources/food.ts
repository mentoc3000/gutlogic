import express, { Request, Response } from "express";
import edamam, { EdamamFoodMeasures, EdamamMeasure } from "../edamam/edamam";
import irritantDb, { irritantsInFood, Irritant } from './irritant_db';
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
  const irritants = await irritantsInFood(db, edamamFoodMeasures.food.foodId);

  return {
    id: edamamFoodMeasures.food.foodId,
    name: edamamFoodMeasures.food.label,
    brand: edamamFoodMeasures.food.brand,
    measures,
    irritants,
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

const router = express.Router();

router.get("/v0/search", search);
router.get("/v0/:foodID", get);

export default router;