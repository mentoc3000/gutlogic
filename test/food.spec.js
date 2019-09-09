const { API, graphqlOperation } = require('aws-amplify');
const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { config, signIn, signOut } = require('./aws-setup');
const dummyDb = require('./dummyDb');

API.configure(config);

chai.use(assertArrays);
const { expect } = chai;

describe('Food database', () => {
  before('Sign in', signIn);
  after('Sign out', signOut);

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

      const result = await API.graphql(graphqlOperation(query));
      const data = result.data.listFoods;
      expect(data.items).to.be.array();
    });
  });

  describe.skip('createFood', () => {
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

  describe.skip('getFood', () => {
    let id;
    const name = 'Bacon';

    before('create a food', async () => {
      id = await dummyDb.createFood(name);
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
        variables: id,
      });
      const getData = getResult.data.getFood;
      expect(getData.__typename).to.equal('Food');
      expect(getData.name).to.equal(name);
    });
  });

  describe.skip('deleteFood', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      id = await dummyDb.createFood(name);
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
          input: id,
        },
      });
      const data = result.data.deleteFood;
      expect(data.__typename).to.equal('Food');
      expect(data.nameId).to.equal(id.nameId);
      expect(data.entryId).to.equal(id.entryId);
    });
  });

  describe.skip('updateFood', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      id = await dummyDb.createFood(name);
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
            nameId: id.nameId,
            entryId: id.entryId,
            name: newName,
          },
        },
      });
      const data = result.data.updateFood;
      expect(data.name).to.equal(newName);
    });
  });
});
