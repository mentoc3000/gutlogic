const dummyDb = require('./dummyDb');

const foodNames = ['Apple', 'Bread', 'Cream Cheese'];

Promise.all(foodNames.map(async name => dummyDb.createFood(name))).then(() => {
  console.log('Foods created.');
});
