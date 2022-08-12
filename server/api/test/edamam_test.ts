// import { assertEquals } from "x/std/testing/asserts.ts";
import { assertEquals } from "https://deno.land/std@0.151.0/testing/asserts.ts";
import { returnsNext, stub } from "https://deno.land/std@0.151.0/testing/mock.ts";
import responses from "test/edamam_responses.json" assert { type: "json" };
import { unwrap } from "../src/result.ts";
import edamam, { EdamamError } from "../src/edamam/edamam.ts";

function getFetchStub(status: number, body: string) {
  const init = { status };
  const response2 = new Response(body, init);
  const promise = new Promise<Response>((resolve, response) => resolve(response2));
  return stub(window, "fetch", returnsNext([promise]));
}

Deno.test("Returns search result", async () => {
  const status = 200;
  const body = responses.search.apple;
  const fetchStub = getFetchStub(status, body);

  try {
    const result = await edamam.search({ name: "apple" });
    const edamamFoodMeasures = unwrap(result);
    const edamamFoodMeasure = edamamFoodMeasures[3];
    assertEquals(edamamFoodMeasure.food?.foodId, "food_amhlqj0by3ozesbg96kkhar1atxt");
  } finally {
    fetchStub.restore();
  }
});

Deno.test("Returns search result", async () => {
  const status = 200;
  const body = responses.search.apple;
  const fetchStub = getFetchStub(status, body);

  try {
    const result = await edamam.search({ name: "apple" });
    const edamamFoodMeasures = unwrap(result);
    const edamamFoodMeasure = edamamFoodMeasures[3];
    assertEquals(edamamFoodMeasure.food?.foodId, "food_amhlqj0by3ozesbg96kkhar1atxt");
  } finally {
    fetchStub.restore();
  }
});

Deno.test("Returns get result", async () => {
  const status = 200;
  const foodId = "food_arpwzeqanprx8zb88lm78a51xaa5";
  const label = "Pizza";
  const body = responses.get.pizza;
  const fetchStub = getFetchStub(status, body);

  try {
    const result = await edamam.get({ foodId, label });
    const edamamFoodMeasure = unwrap(result);
    assertEquals(edamamFoodMeasure.food?.foodId, foodId);
    assertEquals(edamamFoodMeasure.food?.label, label);
  } finally {
    fetchStub.restore();
  }
});

Deno.test("Returns no result with mismatched label", async () => {
  const status = 200;
  const foodId = "food_arpwzeqanprx8zb88lm78a51xaa5";
  const label = "Apple";
  const body = responses.get.pizza;
  const fetchStub = getFetchStub(status, body);

  try {
    const result = await edamam.get({ foodId, label });
    assertEquals(result.ok, false);
  } finally {
    fetchStub.restore();
  }
});
