const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');
const dummyDb = require('./dummyDb');

chai.use(assertArrays);
const { expect } = chai;

describe('Medicine database', () => {
  describe('listMedicines', () => {
    it('should get all medicines', async () => {
      const query = gql(`
        query ListMedicines {
        listMedicines {
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
      const data = result.data.listMedicines;
      expect(data.__typename).to.equal('PaginatedMedicines');
      expect(data.items).to.be.array();
    });
  });

  describe('createMedicine', () => {
    it('should create a medicine', async () => {
      const mutation = gql(`
        mutation CreateMedicine($input: CreateMedicineInput!) {
        createMedicine(input: $input) {
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
      const data = result.data.createMedicine;
      expect(data.__typename).to.equal('Medicine');
      expect(data.name).to.equal('Bacon');
      expect(data.nameId).to.equal('medicine');
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
        query getMedicine($nameId: String!, $entryId: String!) {
        getMedicine(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            name
        }
        }`);

      const getResult = await client.query({
        query: getMedicine,
        variables: id,
      });
      const getData = getResult.data.getMedicine;
      expect(getData.__typename).to.equal('Medicine');
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
        mutation DeleteMedicine($input: GutAiIdInput!) {
        deleteMedicine(input: $input) {
            nameId
            entryId
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation: deleteMedicine,
        variables: {
          input: id,
        },
      });
      const data = result.data.deleteMedicine;
      expect(data.__typename).to.equal('Medicine');
      expect(data.nameId).to.equal(id.nameId);
      expect(data.entryId).to.equal(id.entryId);
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
            nameId
            entryId
            name
        }
        }`);

      const newName = 'Mimosa';

      const result = await client.mutate({
        mutation: updateMedicine,
        variables: {
          input: {
            nameId: id.nameId,
            entryId: id.entryId,
            name: newName,
          },
        },
      });
      const data = result.data.updateMedicine;
      expect(data.name).to.equal(newName);
    });
  });

  after('clear medicine database', dummyDb.clearItems);
});
