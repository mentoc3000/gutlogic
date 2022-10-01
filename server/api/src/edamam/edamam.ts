import urlcat from "urlcat";
import axios from 'axios';
import log from "../resources/logger";
import { err, ok, Result } from "../result";

export type EdamamQualifier = { uri: string | null; label: string | null; };

export type EdamamQualifiedMeasure = {
  qualifiers: EdamamQualifier[] | null;
  weight: number | null;
};

export type EdamamNutrients = {
  ENERC_KAL: number | null;
  PROCNT: number | null;
  FAT: number | null;
  CHOCDF: number | null;
  FIBTG: number | null;
};

export type EdamamFood = {
  foodId: string | null;
  label: string | null;
  nutrients: EdamamNutrients | null;
  brand: string | null;
  category: string | null;
  categoryLabel: string | null;
  foodContentsLabel: string | null;
  image: string | null;
};

export type EdamamMeasure = {
  label: string | null;
  weight: number | null;
  uri: string | null;
  qualified: EdamamQualifiedMeasure[] | null;
};

export type EdamamFoodMeasures = {
  food: EdamamFood | null;
  measures: EdamamMeasure[] | null;
};

type EdamamResponse = { hints: EdamamFoodMeasures[]; };

export const enum EdamamError {
  Unavailable,
  NotFound,
}

// Fetch JSON from the Edamam Parser API with a query.
async function edamam(query: any): Promise<EdamamResponse> {
  const edamamURL = "https://api.edamam.com/api/food-database/v2/parser";

  const key = {
    app_id: "47b2ce40",
    app_key: "6baa72019f5be55b501442052edf134b",
  };

  const url = urlcat(edamamURL, { ...key, ...query });
  const { data } = await axios.get(url);
  return data;
}

// Search Edamam foods by name.
export async function search(
  { name }: { name: string; },
): Promise<Result<EdamamFoodMeasures[], EdamamError>> {
  try {
    const data = await edamam({ ingr: name });
    return ok(data.hints); // ignore edamams suggested result and return full list (called `hints`)
  } catch {
    log.w("Edamam is unavailable");
    return err(EdamamError.Unavailable);
  }
}

// Get an Edamam food by [id], returning the first result. If a [name] is provided, return the first result with a matching name.
export async function get(
  { foodId, label }: { foodId: string; label: string | null | undefined; },
): Promise<Result<EdamamFoodMeasures, EdamamError>> {
  try {
    const data = await edamam({ ingr: foodId }); // edamam has no direct lookup of foods by ID, reuse search API
    const resultWithMatchingID = data.hints.find((e: any) =>
      e.food.foodId === foodId && (!label || e.food.label === label)
    );
    if (resultWithMatchingID === undefined) return err(EdamamError.NotFound);
    return ok(resultWithMatchingID);
  } catch {
    log.w("Edamam is unavailable");
    return err(EdamamError.Unavailable);
  }
}

export default { get, search };
