const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');
const dummyDb = require('./dummyDb');

chai.use(assertArrays);
const { expect } = chai;

describe('Ingredient database', () => {
  const userId = 'fakeuserid';
  const mealEntryId = {
    nameId: 'meal',
    entryId: 'entry',
  };
  const foodId = {
    nameId: 'food',
    entryId: 'entry',
  };

  describe('listIngredients', () => {
    it('should get all ingredients', async () => {
      const query = gql(`
        query ListIngredients {
        listIngredients {
            items {
                nameId
                entryId
            }
        }
        }`);

      await client.hydrated();
      const result = await client.query({ query });
      const data = result.data.listIngredients;
      expect(data.__typename).to.equal('Ingredients');
      expect(data.items).to.be.array();
    });
  });

  describe('createIngredient', () => {
    it('should create a ingredient', async () => {
      const quantity = {
        amount: 0.3,
        unit: 'each',
      };
      const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation,
        variables: {
          input: {
            userId,
            mealEntryId,
            foodId,
            quantity,
          },
        },
      });
      const data = result.data.createIngredient;
      expect(data.__typename).to.equal('Ingredient');
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('addIngredient', () => {
    let mealEntryId2;
    before('create meal', async () => {
      const datetime = '2019-07-02T12:43:00Z';
      mealEntryId2 = await dummyDb.createMealEntry(userId, datetime);
    });

    it('should add a ingredient', async () => {
      const quantity = {
        amount: 0.3,
        unit: 'each',
      };
      const mutation = gql(`
        mutation AddIngredient($input: CreateIngredientInput!) {
        addIngredient(input: $input) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      await client.hydrated();
      await client.mutate({
        mutation,
        variables: {
          input: {
            userId,
            mealEntryId: mealEntryId2,
            foodId,
            quantity,
          },
        },
      });

      const getDiaryEntry = gql(`
        query getDiaryEntry($nameId: String!, $entryId: String!) {
        getDiaryEntry(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            meal {
              ingredients { nameId }
            }
        }
        }`);

      const getResult = await client.query({
        query: getDiaryEntry,
        variables: mealEntryId2,
      });

      const getData = getResult.data.getDiaryEntry;
      expect(getData.meal.ingredients).to.be.array();
      expect(getData.meal.ingredients.length).to.equal(1);
      expect(getData.meal.ingredients[0].nameId).to.equal(userId);
    });
  });

  describe('getIngredient', () => {
    let id;
    const amount = 2.4;
    const unit = 'cups';
    const foodName = 'Flour';
    const datetime = '2019-07-02T12:43:00Z';

    before('create a ingredient', async () => {
      const mealEntryId2 = await dummyDb.createMealEntry('userid', datetime);
      const foodId2 = await dummyDb.createFood(foodName);
      id = await dummyDb.createIngredient(
        userId,
        mealEntryId2,
        foodId2,
        amount,
        unit
      );
    });

    it('should get an ingredient', async () => {
      const getIngredient = gql(`
        query getIngredient($nameId: String!, $entryId: String!) {
        getIngredient(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      const getResult = await client.query({
        query: getIngredient,
        variables: id,
      });
      const getData = getResult.data.getIngredient;
      expect(getData.__typename).to.equal('Ingredient');
      expect(getData.quantity.amount).to.equal(amount);
      expect(getData.quantity.unit).to.equal(unit);
    });

    it("should get an ingredient's food name", async () => {
      const getIngredient = gql(`
        query getIngredient($nameId: String!, $entryId: String!) {
        getIngredient(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            food { name }
        }
        }`);

      const getResult = await client.query({
        query: getIngredient,
        variables: id,
      });
      const getData = getResult.data.getIngredient;
      expect(getData.food.name).to.equal(foodName);
    });

    it("should get an ingredient's meal entry", async () => {
      const getIngredient = gql(`
        query getIngredient($nameId: String!, $entryId: String!) {
        getIngredient(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            mealEntry { datetime }
        }
        }`);

      const getResult = await client.query({
        query: getIngredient,
        variables: id,
      });
      const getData = getResult.data.getIngredient;
      expect(getData.mealEntry.datetime).to.equal(datetime);
    });
  });

  describe('deleteIngredient', () => {
    let id;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a ingredient', async () => {
      id = await dummyDb.createIngredient(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should delete a ingredient', async () => {
      const deleteIngredient = gql(`
        mutation DeleteIngredient($input: GutAiIdInput!) {
        deleteIngredient(input: $input) {
            nameId
            entryId
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation: deleteIngredient,
        variables: {
          input: id,
        },
      });
      const data = result.data.deleteIngredient;
      expect(data.__typename).to.equal('Ingredient');
      expect(data.nameId).to.equal(id.nameId);
      expect(data.entryId).to.equal(id.entryId);
    });
  });

  describe('updateIngredient', () => {
    let id;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a ingredient', async () => {
      id = await dummyDb.createIngredient(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should update a ingredient', async () => {
      const updateIngredient = gql(`
        mutation UpdateIngredient($input: UpdateIngredientInput!) {
        updateIngredient(input: $input) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      const quantity = {
        amount: 1.2,
        unit: 'Tbps',
      };

      const result = await client.mutate({
        mutation: updateIngredient,
        variables: {
          input: {
            nameId: id.nameId,
            entryId: id.entryId,
            quantity,
          },
        },
      });
      const data = result.data.updateIngredient;
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  after('clear ingredient database', dummyDb.clearItems);
});
