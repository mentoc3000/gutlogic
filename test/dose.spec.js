const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');

chai.use(assertArrays);
const { expect } = chai;

const clearDoseDb = async () => {
  const listDoses = gql(`
    query ListDoses {
    listDoses {
        items {
            nameId
            entryId
        }
    }
    }`);

  await client.hydrated();
  const result = await client.query({
    query: listDoses,
    fetchPolicy: 'network-only',
  });

  await result.data.listDoses.items.forEach(async item => {
    const deleteDose = gql(`
      mutation DeleteDose($input: GutAiIdInput!) {
      deleteDose(input: $input) {
          nameId
          entryId
      }
      }`);

    await client.mutate({
      mutation: deleteDose,
      variables: {
        input: {
          nameId: item.nameId,
          entryId: item.entryId,
        },
      },
    });
  });
};

const createDose = async (userId, dosesEntryId, medicineId, amount, unit) => {
  const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
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
        dosesEntryId,
        medicineId,
        quantity: { amount, unit },
      },
    },
  });
  const createData = createResult.data.createDose;
  return [createData.nameId, createData.entryId];
};

describe('Dose database', () => {
  const userId = 'fakeuserid';
  const dosesEntryId = {
    nameId: 'meal',
    entryId: 'entry',
  };
  const medicineId = {
    nameId: 'food',
    entryId: 'entry',
  };

  before('clear dose database', clearDoseDb);

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
            dosesEntryId,
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
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    before('create a dose', async () => {
      [nameId, entryId] = await createDose(
        userId,
        dosesEntryId,
        medicineId,
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
        variables: { nameId, entryId },
      });
      const getData = getResult.data.getDose;
      expect(getData.__typename).to.equal('Dose');
      expect(getData.quantity.amount).to.equal(amount);
      expect(getData.quantity.unit).to.equal(unit);
    });
  });

  describe('deleteDose', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a dose', async () => {
      [nameId, entryId] = await createDose(
        userId,
        dosesEntryId,
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
          input: { nameId, entryId },
        },
      });
      const data = result.data.deleteDose;
      expect(data.__typename).to.equal('Dose');
      expect(data.nameId).to.equal(nameId);
      expect(data.entryId).to.equal(entryId);
    });
  });

  describe('updateDose', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a dose', async () => {
      [nameId, entryId] = await createDose(
        userId,
        dosesEntryId,
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
          input: { nameId, entryId, quantity },
        },
      });
      const data = result.data.updateDose;
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  // after('clear dose database', clearDoseDb);
});
