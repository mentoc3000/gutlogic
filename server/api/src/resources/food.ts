import { Request, Response, Router } from "x/oak/mod.ts";
import edamam, { EdamamFoodMeasures, EdamamMeasure } from "../edamam/edamam.ts";

export type Measure = {
  unit: string;
  weight: number;
};

export type Food = {
  id: string;
  name: string;
  brand: string | null;
  measures: Measure[];
};

function isValidLabel(label: string | null): boolean {
  return label != null && label != "";
}

function isValidWeight(weight: number | null): boolean {
  return weight != null && weight > 0;
}

function genericizeEdamamMeasure(edamamMeasure: EdamamMeasure): Measure[] {
  var measures: Measure[] = [];

  if (
    isValidLabel(edamamMeasure.label) && isValidWeight(edamamMeasure.weight)
  ) {
    measures.push({
      unit: edamamMeasure.label!,
      weight: edamamMeasure.weight!,
    });
  }

  if (edamamMeasure.qualified != null && edamamMeasure.qualified.length == 0) {
    for (var qualifiedMeasure of edamamMeasure.qualified) {
      if (qualifiedMeasure.qualifiers != null) {
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

function genericizeEdamamFoodMeasures(
  edamamFoodMeasures: EdamamFoodMeasures,
): Food | null {
  if (!(edamamFoodMeasures?.food?.foodId)) return null;
  if (!(edamamFoodMeasures?.food?.label)) return null;

  const measures = edamamFoodMeasures?.measures?.map(genericizeEdamamMeasure).reduce(
    (acc, el) => acc.concat(el),
    [],
  ) ?? [];

  return {
    id: edamamFoodMeasures.food.foodId,
    name: edamamFoodMeasures.food.label,
    brand: edamamFoodMeasures.food.brand,
    measures: measures,
  };
}

async function get(
  { params, request, response }: {
    params: any;
    request: Request;
    response: Response;
  },
) {
  const name = request.url.searchParams.get("name");

  const foodID = params.foodID;
  const result = await edamam.get({ foodId: foodID, label: name });

  if (result.ok) {
    response.body = { data: genericizeEdamamFoodMeasures(result.value) };
  } else {
    response.status = 404;
  }
}

async function search(
  { request, response }: { request: Request; response: Response },
) {
  const name = request.url.searchParams.get("name");

  if (name == null) {
    response.status = 400;
    return;
  }

  const result = await edamam.search({ name: name });

  if (result.ok) {
    response.body = { data: result.value.map(genericizeEdamamFoodMeasures) };
  } else {
    response.body = { data: [] };
  }
}

const router = new Router();

router.get("/v0/search", search);
router.get("/v0/:foodID", get);

export default router;

/// Begin regular api calls to Edamam server
///
/// The first call to the Edamam server is always slow, taking several sections. Subsequent ones
/// are fast, taking less than one second. Once Edamam has not gotten a request for 60 minutes
/// it is slow to start again. This function makes a request of Edamam every 20 minutes to ensure
/// the user always sees a speedy response.
export function startEdamamHeartbeat() {
  const heartbeatInterval = 20 * 60 * 1000; // 20 minutes
  const foodId = "food_a1gb9ubb72c7snbuxr3weagwv0dd";
  setInterval(() => edamam.get({ foodId: foodId, label: "Apple" }), heartbeatInterval);
}
