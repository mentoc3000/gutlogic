import express, { Request, Response } from "express";

import IrritantDb, { getFoodGroups, getIrritantData, getIrritants } from './irritant_db';
import log from './logger';

const irritantDb = new IrritantDb();

async function foodGroups(req: Request, res: Response) {
  try {
    const db = await irritantDb.get();
    const foods = await getFoodGroups(db);
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
    const thresholds = await getIrritantData(db);
    res.json({ data: thresholds });
  } catch (e) {
    res.status(500).end();
    log.e(JSON.stringify(e, Object.getOwnPropertyNames(e)));
  }
}

async function elementaryFoods(req: Request, res: Response) {
  try {
    const db = await irritantDb.get();
    const foods = await getIrritants(db);
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