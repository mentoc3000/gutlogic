const { API, graphqlOperation } = require('aws-amplify');
const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { config, signIn, signOut } = require('./aws-setup');
const dummyDb = require('./dummyDb');

API.configure(config);

chai.use(assertArrays);
const { expect } = chai;

describe('Medicine database', () => {
  before('Sign in', signIn);
  after('Sign out', async () => {
    await dummyDb.clearItems();
    await signOut();
  });

  describe('listMedicines', () => {
    it('should get all medicines', async () => {
      const query = gql(`
        query ListMedicines {
        listMedicines {
          items {
            id
            name
          }
          nextToken
        }
        }`);

      const result = await API.graphql(graphqlOperation(query));
      const data = result.data.listMedicines;
      expect(data.items).to.be.array();
    });
  });

  describe('createMedicine', () => {
    it('should create a medicine', async () => {
      const mutation = gql(`
        mutation CreateMedicine($input: CreateMedicineInput!) {
        createMedicine(input: $input) {
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
      const data = result.data.createMedicine;
      expect(data.name).to.equal('Bacon');
    });
  });

  describe('getMedicine', () => {
    let id;
    const name = 'Bacon';

    before('create a medicine', async () => {
      id = await dummyDb.createMedicine(name);
    });

    it('should get a medicine', async () => {
      const getMedicine = gql(`
        query GetMedicine($id: ID!) {
        getMedicine(id: $id) {
          id
          name
        }
        }`);

      const getResult = await API.graphql(
        graphqlOperation(getMedicine, { id })
      );
      const getData = getResult.data.getMedicine;
      expect(getData.name).to.equal(name);
    });
  });

  describe('deleteMedicine', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a medicine', async () => {
      id = await dummyDb.createMedicine(name);
    });

    it('should delete a medicine', async () => {
      const deleteMedicine = gql(`
        mutation DeleteMedicine($input: DeleteMedicineInput!) {
        deleteMedicine(input: $input) {
          id
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(deleteMedicine, { input: { id } })
      );
      const data = result.data.deleteMedicine;
      expect(data.id).to.equal(id);
    });
  });

  describe('updateMedicine', () => {
    let id;
    const name = 'Bacon';

    beforeEach('create a medicine', async () => {
      id = await dummyDb.createMedicine(name);
    });

    it('should update a medicine', async () => {
      const updateMedicine = gql(`
        mutation UpdateMedicine($input: UpdateMedicineInput!) {
        updateMedicine(input: $input) {
          id
          name
        }
        }`);

      const newName = 'Mimosa';

      const result = await API.graphql(
        graphqlOperation(updateMedicine, {
          input: {
            id,
            name: newName,
          },
        })
      );
      const data = result.data.updateMedicine;
      expect(data.name).to.equal(newName);
    });
  });
});
