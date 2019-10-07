const { API, graphqlOperation } = require('aws-amplify');
const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { config, signIn, signOut } = require('./aws-setup');
const dummyDb = require('./dummyDb');

API.configure(config);

chai.use(assertArrays);
const { expect } = chai;

describe('Ingredient database', () => {
  before('Sign in', signIn);
  after('Sign out', async () => {
    await dummyDb.clearItems();
    await signOut();
  });

  describe('listIngredients', () => {
    it('should get all ingredients', async () => {
      const query = gql(`
        query ListIngredients {
        listIngredients {
          items {
            id
            food { name }
          }
          nextToken
        }
        }`);

      const result = await API.graphql(graphqlOperation(query));
      const data = result.data.listIngredients;
      expect(data.items).to.be.array();
    });
  });

  describe('createIngredient', () => {
    const foodName = 'Rice Cake';
    const datetime = '2019-07-02T12:43:00Z';
    let ingredientFoodId;
    let ingredientDiaryEntryId;

    before('create food', async () => {
      ingredientFoodId = await dummyDb.createFood(foodName);
      ingredientDiaryEntryId = await dummyDb.createMealEntry(datetime);
    });

    it('should create a ingredient', async () => {
      const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
            id
            food { name }
            quantity {
              amount
              unit
            }
        }
        }`);
      const quantity = {
        amount: 2,
        unit: 'each',
      };
      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            ingredientDiaryEntryId,
            ingredientFoodId,
            quantity,
          },
        })
      );
      const data = result.data.createIngredient;
      expect(data.food.name).to.equal(foodName);
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('getIngredient', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let ingredientFoodId;
    let ingredientDiaryEntryId;
    let ingredientId;
    const foodName = 'Bacon';
    const quantity = {
      amount: 1.5,
      unit: 'slices',
    };

    before('create a ingredient', async () => {
      ingredientFoodId = await dummyDb.createFood(foodName);
      ingredientDiaryEntryId = await dummyDb.createMealEntry(datetime);
      ingredientId = await dummyDb.createIngredient(
        ingredientDiaryEntryId,
        ingredientFoodId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should get a ingredient', async () => {
      const getIngredient = gql(`
        query GetIngredient($id: ID!) {
        getIngredient(id: $id) {
          id
          food { name }
          quantity {
            amount
            unit
          }
        }
        }`);

      const getResult = await API.graphql(
        graphqlOperation(getIngredient, { id: ingredientId })
      );
      const getData = getResult.data.getIngredient;
      expect(getData.food.name).to.equal(foodName);
      expect(getData.quantity.amount).to.equal(quantity.amount);
      expect(getData.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('deleteIngredient', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let ingredientFoodId;
    let ingredientDiaryEntryId;
    let ingredientId;
    const foodName = 'Bacon';
    const quantity = {
      amount: 1.5,
      unit: 'slices',
    };

    before('create a ingredient', async () => {
      ingredientFoodId = await dummyDb.createFood(foodName);
      ingredientDiaryEntryId = await dummyDb.createMealEntry(datetime);
      ingredientId = await dummyDb.createIngredient(
        ingredientDiaryEntryId,
        ingredientFoodId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should delete a ingredient', async () => {
      const deleteIngredient = gql(`
        mutation DeleteIngredient($input: DeleteIngredientInput!) {
        deleteIngredient(input: $input) {
          id
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(deleteIngredient, {
          input: {
            id: ingredientId,
            expectedVersion: 1,
          },
        })
      );
      const data = result.data.deleteIngredient;
      expect(data.id).to.equal(ingredientId);
    });
  });

  describe('updateIngredient', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let ingredientFoodId;
    let ingredientDiaryEntryId;
    let ingredientId;
    const foodName = 'Bacon';
    const quantity = {
      amount: 1.5,
      unit: 'slices',
    };

    before('create a ingredient', async () => {
      ingredientFoodId = await dummyDb.createFood(foodName);
      ingredientDiaryEntryId = await dummyDb.createMealEntry(datetime);
      ingredientId = await dummyDb.createIngredient(
        ingredientDiaryEntryId,
        ingredientFoodId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should update a ingredient', async () => {
      const updateIngredient = gql(`
        mutation UpdateIngredient($input: UpdateIngredientInput!) {
        updateIngredient(input: $input) {
          id
          quantity { amount }
          version
        }
        }`);

      const newAmount = 3.5;

      const result = await API.graphql(
        graphqlOperation(updateIngredient, {
          input: {
            id: ingredientId,
            expectedVersion: 1,
            quantity: {
              amount: newAmount,
            },
          },
        })
      );
      const data = result.data.updateIngredient;
      expect(data.quantity.amount).to.equal(newAmount);
      expect(data.version).to.equal(2);
    });
  });
});
