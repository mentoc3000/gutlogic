const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');

chai.use(assertArrays);
const { expect } = chai;

const clearIngredientDb = async () => {
  const listIngredients = gql(`
    query ListIngredients {
    listIngredients {
        items {
            nameId
            entryId
        }
    }
    }`);

  await client.hydrated();
  const result = await client.query({
    query: listIngredients,
    fetchPolicy: 'network-only',
  });

  await result.data.listIngredients.items.forEach(async item => {
    const deleteIngredient = gql(`
      mutation DeleteIngredient($input: GutAiIdInput!) {
      deleteIngredient(input: $input) {
          nameId
          entryId
      }
      }`);

    await client.mutate({
      mutation: deleteIngredient,
      variables: {
        input: {
          nameId: item.nameId,
          entryId: item.entryId,
        },
      },
    });
  });
};

const createIngredient = async (userId, mealEntryId, foodId, amount, unit) => {
  const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
            nameId
            entryId
        }
        }`);

  await client.hydrated();
  const createResult = await client.mutate({
    mutation,
    variables: {
      input: {
        userId,
        mealEntryId,
        foodId,
        quantity: { amount, unit },
      },
    },
  });
  const createData = createResult.data.createIngredient;
  return [createData.nameId, createData.entryId];
};

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

  before('clear ingredient database', clearIngredientDb);

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

  describe('getIngredient', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    before('create a ingredient', async () => {
      [nameId, entryId] = await createIngredient(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should get a ingredient', async () => {
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
        variables: { nameId, entryId },
      });
      const getData = getResult.data.getIngredient;
      expect(getData.__typename).to.equal('Ingredient');
      expect(getData.quantity.amount).to.equal(amount);
      expect(getData.quantity.unit).to.equal(unit);
    });
  });

  describe('deleteIngredient', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a ingredient', async () => {
      [nameId, entryId] = await createIngredient(
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
          input: { nameId, entryId },
        },
      });
      const data = result.data.deleteIngredient;
      expect(data.__typename).to.equal('Ingredient');
      expect(data.nameId).to.equal(nameId);
      expect(data.entryId).to.equal(entryId);
    });
  });

  describe('updateIngredient', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a ingredient', async () => {
      [nameId, entryId] = await createIngredient(
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
          input: { nameId, entryId, quantity },
        },
      });
      const data = result.data.updateIngredient;
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  // after('clear ingredient database', clearIngredientDb);
});
