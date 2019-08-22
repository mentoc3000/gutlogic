const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');
const dummyDb = require('./dummyDb');

chai.use(assertArrays);
const { expect } = chai;

describe('Dose database', () => {
  const userId = 'fakeuserid';
  const dosageEntryId = {
    nameId: 'meal',
    entryId: 'entry',
  };
  const medicineId = {
    nameId: 'food',
    entryId: 'entry',
  };

  describe('listDoses', () => {
    it('should get all doses', async () => {
      const query = gql(`
        query ListDoses {
        listDoses {
            items {
                nameId
                entryId
            }
        }
        }`);

      await client.hydrated();
      const result = await client.query({ query });
      const data = result.data.listDoses;
      expect(data.__typename).to.equal('Doses');
      expect(data.items).to.be.array();
    });
  });

  describe('createDose', () => {
    it('should create a dose', async () => {
      const quantity = {
        amount: 0.3,
        unit: 'each',
      };
      const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
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
            dosageEntryId,
            medicineId,
            quantity,
          },
        },
      });
      const data = result.data.createDose;
      expect(data.__typename).to.equal('Dose');
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('getDose', () => {
    let id;
    const amount = 3;
    const unit = 'pills';
    const medicineName = 'Pro-8';
    const datetime = '2019-07-02T12:43:00Z';

    before('create a dose', async () => {
      const medicineId2 = await dummyDb.createMedicine(medicineName);
      const dosageEntryId2 = await dummyDb.createDosageEntry(userId, datetime);
      id = await dummyDb.createDose(
        userId,
        dosageEntryId2,
        medicineId2,
        amount,
        unit
      );
    });

    it('should get a dose', async () => {
      const getDose = gql(`
        query getDose($nameId: String!, $entryId: String!) {
        getDose(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      const getResult = await client.query({
        query: getDose,
        variables: id,
      });
      const getData = getResult.data.getDose;
      expect(getData.__typename).to.equal('Dose');
      expect(getData.quantity.amount).to.equal(amount);
      expect(getData.quantity.unit).to.equal(unit);
    });

    it("should get a dose's medicine", async () => {
      const getDose = gql(`
        query getDose($nameId: String!, $entryId: String!) {
        getDose(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            medicine { name }
        }
        }`);

      const getResult = await client.query({
        query: getDose,
        variables: id,
      });
      const getData = getResult.data.getDose;
      expect(getData.medicine.name).to.equal(medicineName);
    });

    it("should get a dose's diary entry", async () => {
      const getDose = gql(`
        query getDose($nameId: String!, $entryId: String!) {
        getDose(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            dosageEntry { datetime }
        }
        }`);

      const getResult = await client.query({
        query: getDose,
        variables: id,
      });
      const getData = getResult.data.getDose;
      expect(getData.dosageEntry.datetime).to.equal(datetime);
    });
  });

  describe('deleteDose', () => {
    let id;
    const amount = 3;
    const unit = 'pills';

    beforeEach('create a dose', async () => {
      id = await dummyDb.createDose(
        userId,
        dosageEntryId,
        medicineId,
        amount,
        unit
      );
    });

    it('should delete a dose', async () => {
      const deleteDose = gql(`
        mutation DeleteDose($input: GutAiIdInput!) {
        deleteDose(input: $input) {
            nameId
            entryId
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation: deleteDose,
        variables: {
          input: id,
        },
      });
      const data = result.data.deleteDose;
      expect(data.__typename).to.equal('Dose');
      expect(data.nameId).to.equal(id.nameId);
      expect(data.entryId).to.equal(id.entryId);
    });
  });

  describe('updateDose', () => {
    let id;
    const amount = 3;
    const unit = 'pills';

    beforeEach('create a dose', async () => {
      id = await dummyDb.createDose(
        userId,
        dosageEntryId,
        medicineId,
        amount,
        unit
      );
    });

    it('should update a dose', async () => {
      const updateDose = gql(`
        mutation UpdateDose($input: UpdateDoseInput!) {
        updateDose(input: $input) {
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
        mutation: updateDose,
        variables: {
          input: {
            nameId: id.nameId,
            entryId: id.entryId,
            quantity,
          },
        },
      });
      const data = result.data.updateDose;
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  after('clear dose database', dummyDb.clearItems);
});
