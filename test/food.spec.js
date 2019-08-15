const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');

chai.use(assertArrays);
const { expect } = chai;

const clearFoodDb = async () => {
  const listFoods = gql(`
    query ListFoods {
    listFoods {
        items {
            nameId
            entryId
            name
        }
        nextToken
    }
    }`);

  await client.hydrated();
  const result = await client.query({
    query: listFoods,
    fetchPolicy: 'network-only',
  });

  await result.data.listFoods.items.forEach(async item => {
    const deleteFood = gql(`
      mutation DeleteFood($input: GutAiIdInput!) {
      deleteFood(input: $input) {
          nameId
          entryId
      }
      }`);

    await client.mutate({
      mutation: deleteFood,
      variables: {
        input: {
          nameId: item.nameId,
          entryId: item.entryId,
        },
      },
    });
  });
};

const createFood = async name => {
  const mutation = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

  await client.hydrated();
  const createResult = await client.mutate({
    mutation,
    variables: {
      input: { name },
    },
  });
  const createData = createResult.data.createFood;
  return [createData.nameId, createData.entryId];
};

describe('Food database', () => {
  before('clear food database', clearFoodDb);

  describe('listFoods', () => {
    it('should get all foods', async () => {
      const query = gql(`
        query ListFoods {
        listFoods {
            items {
                nameId
                entryId
                name
            }
            nextToken
        }
        }`);

      await client.hydrated();
      const result = await client.query({ query });
      const data = result.data.listFoods;
      expect(data.__typename).to.equal('PaginatedFoods');
      expect(data.items).to.be.array();
    });
  });

  describe('createFood', () => {
    it('should create a food', async () => {
      const mutation = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation,
        variables: {
          input: {
            name: 'Bacon',
          },
        },
      });
      const data = result.data.createFood;
      expect(data.__typename).to.equal('Food');
      expect(data.name).to.equal('Bacon');
      expect(data.nameId).to.equal('food');
    });
  });

  describe('getFood', () => {
    let nameId;
    let entryId;
    const name = 'Bacon';

    before('create a food', async () => {
      [nameId, entryId] = await createFood(name);
    });

    it('should get a food', async () => {
      const getFood = gql(`
        query getFood($nameId: String!, $entryId: String!) {
        getFood(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            name
        }
        }`);

      const getResult = await client.query({
        query: getFood,
        variables: { nameId, entryId },
      });
      const getData = getResult.data.getFood;
      expect(getData.__typename).to.equal('Food');
      expect(getData.name).to.equal(name);
    });
  });

  describe('deleteFood', () => {
    let nameId;
    let entryId;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      [nameId, entryId] = await createFood(name);
    });

    it('should delete a food', async () => {
      const deleteFood = gql(`
        mutation DeleteFood($input: GutAiIdInput!) {
        deleteFood(input: $input) {
            nameId
            entryId
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation: deleteFood,
        variables: {
          input: { nameId, entryId },
        },
      });
      const data = result.data.deleteFood;
      expect(data.__typename).to.equal('Food');
      expect(data.nameId).to.equal(nameId);
      expect(data.entryId).to.equal(entryId);
    });
  });

  describe('updateFood', () => {
    let nameId;
    let entryId;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      [nameId, entryId] = await createFood(name);
    });

    it('should update a food', async () => {
      const updateFood = gql(`
        mutation UpdateFood($input: UpdateFoodInput!) {
        updateFood(input: $input) {
            nameId
            entryId
            name
        }
        }`);

      const newName = 'Mimosa';

      const result = await client.mutate({
        mutation: updateFood,
        variables: {
          input: {
            nameId,
            entryId,
            name: newName,
          },
        },
      });
      const data = result.data.updateFood;
      expect(data.name).to.equal(newName);
    });
  });

  after('clear food database', clearFoodDb);
});
