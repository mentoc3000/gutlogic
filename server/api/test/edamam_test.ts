import test from 'ava';
import * as sinon from 'sinon';
import * as responses from "./edamam_responses.json";
import { unwrap } from "../src/result";
import axios, { AxiosResponse } from 'axios';
import edamam from "../src/edamam/edamam";

var getStub: sinon.SinonStub;

function setFetchStub(status: number, body: string) {
  const response: AxiosResponse = {
    data: JSON.parse(body),
    status,
    statusText: status.toString(),
    headers: null,
    config: null,
  };
  getStub.returns(Promise.resolve(response));
}

test.before(() => {
  getStub = sinon.stub(axios, "get");
});

test.afterEach(sinon.reset);

test("Returns search result", async t => {
  const status = 200;
  const body = responses.search.apple;
  setFetchStub(status, body);

  const result = await edamam.search({ name: "apple" });
  const edamamFoodMeasures = unwrap(result);
  const edamamFoodMeasure = edamamFoodMeasures[3];
  t.is(edamamFoodMeasure.food?.foodId, "food_amhlqj0by3ozesbg96kkhar1atxt");
});

test("Returns get result", async t => {
  const status = 200;
  const foodId = "food_arpwzeqanprx8zb88lm78a51xaa5";
  const label = "Pizza";
  const body = responses.get.pizza;
  setFetchStub(status, body);

  const result = await edamam.get({ foodId, label });
  const edamamFoodMeasure = unwrap(result);
  t.is(edamamFoodMeasure.food?.foodId, foodId);
  t.is(edamamFoodMeasure.food?.label, label);
});

test("Removes incomplete measures", async t => {
  const status = 200;
  const foodId = "food_arpwzeqanprx8zb88lm78a51xaa5";
  const label = "Pizza";
  const body = responses.get.pizza;
  setFetchStub(status, body);

  const result = await edamam.get({ foodId, label });
  const edamamFoodMeasure = unwrap(result);
  edamamFoodMeasure.measures.forEach((m) => t.true(Boolean(m.label) && Boolean(m.weight)));
});

test("Returns no result with mismatched label", async t => {
  const status = 200;
  const foodId = "food_arpwzeqanprx8zb88lm78a51xaa5";
  const label = "Apple";
  const body = responses.get.pizza;
  setFetchStub(status, body);

  const result = await edamam.get({ foodId, label });
  t.is(result.ok, false);
});
