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
  after('Sign out', async () => {
    await dummyDb.clearItems();
    await signOut();
  });

  describe('listFoods', () => {
    it('should get all foods', async () => {
      const query = gql(`
        query ListFoods {
        listFoods {
          items {
            id
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

  describe('createFood', () => {
    it('should create a food', async () => {
      const mutation = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            id
            name
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            name: 'Bacon',
          },
        })
      );
      const data = result.data.createFood;
      expect(data.name).to.equal('Bacon');
    });
  });

  describe('getFood', () => {
    let id;
    const name = 'Bacon';

    before('create a food', async () => {
      id = await dummyDb.createFood(name);
    });

    it('should get a food', async () => {
      const getFood = gql(`
        query GetFood($id: ID!) {
        getFood(id: $id) {
          id
          name
        }
        }`);

      const getResult = await API.graphql(graphqlOperation(getFood, { id }));
      const getData = getResult.data.getFood;
      expect(getData.name).to.equal(name);
    });
  });

  describe('deleteFood', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      id = await dummyDb.createFood(name);
    });

    it('should delete a food', async () => {
      const deleteFood = gql(`
        mutation DeleteFood($input: DeleteFoodInput!) {
        deleteFood(input: $input) {
          id
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(deleteFood, { input: { id } })
      );
      const data = result.data.deleteFood;
      expect(data.id).to.equal(id);
    });
  });

  describe('updateFood', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a food', async () => {
      id = await dummyDb.createFood(name);
    });

    it('should update a food', async () => {
      const updateFood = gql(`
        mutation UpdateFood($input: UpdateFoodInput!) {
        updateFood(input: $input) {
          id
          name
        }
        }`);

      const newName = 'Mimosa';

      const result = await API.graphql(
        graphqlOperation(updateFood, {
          input: {
            id,
            name: newName,
          },
        })
      );
      const data = result.data.updateFood;
      expect(data.name).to.equal(newName);
    });
  });
});
