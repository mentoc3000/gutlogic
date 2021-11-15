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

test('does not get missing food', async (t) => {
  const foodId = 'food_b8yslxla9z81r0bbv1dzpwrtp54l';
  const input = { query: foodId };
  const wrapped = fft.wrap(functions.edamamFoodSearch);
  const { status, data } = await wrapped(input);
  t.is(status, 404);
  t.is(data.error, 'not_found');
});

test('gets many foods', async (t) => {
  const food = 'pizza';
  const input = { query: food };
  const wrapped = fft.wrap(functions.edamamFoodSearch);
  const { status, data } = await wrapped(input);
  t.is(status, 200);
  t.is(data.hints.length, 22);
});
