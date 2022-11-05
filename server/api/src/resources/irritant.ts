import express, { Request, Response } from "express";

import irritantDb, * as idb from './irritant_db';
import log from './logger';


async function foodGroups(req: Request, res: Response) {
  try {
    const db = await irritantDb.get();
    const foods = await idb.foodsInGroups(db);
    const foodGroups = {};
    for (let food of foods) {
      if (!(food.group in foodGroups)) {
        foodGroups[food.group] = [];
      }
      foodGroups[food.group].push(food);
    }
    res.json({ data: foodGroups });
  } catch (e) {
    res.status(500).end();
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
  }
}

async function intensityThresholds(req: Request, res: Response) {
  try {
    const db = await irritantDb.get();
    const thresholds = await idb.irritantThresholds(db);
    res.json({ data: thresholds });
  } catch (e) {
    res.status(500).end();
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
  }
}

async function elementaryFoods(req: Request, res: Response) {
  try {
    const db = await irritantDb.get();
    const foods = await idb.elementaryFoods(db);
    res.json({ data: foods });
  } catch (e) {
    res.status(500).end();
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
  }
}

const router = express.Router();

router.get("/foodGroups", foodGroups);
router.get("/intensityThresholds", intensityThresholds);
router.get("/elementaryFoods", elementaryFoods);

export default router;