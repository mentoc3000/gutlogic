const test = require('ava');

const testHelpers = require('./_helpers');
const fft = testHelpers.firebaseFunctionsTest;

const functions = require('../index');

test.after.always(async () => {
  // Do cleanup tasks.
  fft.cleanup();
});

test('gets a single food', async (t) => {
  const foodId = 'food_axvtyr9anluzygaadzh7ib05jsdg';
  const input = { query: foodId };
  const wrapped = fft.wrap(functions.edamamFoodSearch);
  const { status, data } = await wrapped(input);
  t.is(status, 200);
  t.is(data.hints[0].food.foodId, foodId);
});

test('gets many foods', async (t) => {
  const food = 'pizza';
  const input = { query: food };
  const wrapped = fft.wrap(functions.edamamFoodSearch);
  const { status, data } = await wrapped(input);
  t.is(status, 200);
  t.is(data.hints.length, 22);
});

test('gets irritating food', async (t) => {
  const foodId = 'food_auk9jeqampkhjsbyvvbsdbqyejif';
  const input = { query: foodId };
  const wrapped = fft.wrap(functions.edamamFoodSearch);
  const { status, data } = await wrapped(input);
  t.is(status, 200);
  const food = data.hints[0];
  t.is(food.irritants[0].name, 'Fructose');
  t.is(food.irritants[0].isPresent, true);
  t.is(food.irritants[0].concentration, 0.0316);
});
