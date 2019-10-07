const { API, graphqlOperation } = require('aws-amplify');
const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { config, signIn, signOut } = require('./aws-setup');
const dummyDb = require('./dummyDb');

API.configure(config);

chai.use(assertArrays);
const { expect } = chai;

describe('Dose database', () => {
  before('Sign in', signIn);
  after('Sign out', async () => {
    await dummyDb.clearItems();
    await signOut();
  });

  describe('listDoses', () => {
    it('should get all doses', async () => {
      const query = gql(`
        query ListDoses {
        listDoses {
          items {
            id
            medicine { name }
          }
          nextToken
        }
        }`);

      const result = await API.graphql(graphqlOperation(query));
      const data = result.data.listDoses;
      expect(data.items).to.be.array();
    });
  });

  describe('createDose', () => {
    const medicineName = 'Rice Cake';
    const datetime = '2019-07-02T12:43:00Z';
    let doseMedicineId;
    let doseDiaryEntryId;

    before('create medicine', async () => {
      doseMedicineId = await dummyDb.createMedicine(medicineName);
      doseDiaryEntryId = await dummyDb.createDosageEntry(datetime);
    });

    it('should create a dose', async () => {
      const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
            id
            medicine { name }
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
            doseDiaryEntryId,
            doseMedicineId,
            quantity,
          },
        })
      );
      const data = result.data.createDose;
      expect(data.medicine.name).to.equal(medicineName);
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('getDose', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let doseMedicineId;
    let doseDiaryEntryId;
    let doseId;
    const medicineName = 'Camphor Oil';
    const quantity = {
      amount: 1.5,
      unit: 'Tbps',
    };

    before('create a dose', async () => {
      doseMedicineId = await dummyDb.createMedicine(medicineName);
      doseDiaryEntryId = await dummyDb.createDosageEntry(datetime);
      doseId = await dummyDb.createDose(
        doseDiaryEntryId,
        doseMedicineId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should get a dose', async () => {
      const getDose = gql(`
        query GetDose($id: ID!) {
        getDose(id: $id) {
          id
          medicine { name }
          quantity {
            amount
            unit
          }
        }
        }`);

      const getResult = await API.graphql(
        graphqlOperation(getDose, { id: doseId })
      );
      const getData = getResult.data.getDose;
      expect(getData.medicine.name).to.equal(medicineName);
      expect(getData.quantity.amount).to.equal(quantity.amount);
      expect(getData.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe('deleteDose', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let doseMedicineId;
    let doseDiaryEntryId;
    let doseId;
    const medicineName = 'Camphor Oil';
    const quantity = {
      amount: 1.5,
      unit: 'Tbps',
    };

    before('create a dose', async () => {
      doseMedicineId = await dummyDb.createMedicine(medicineName);
      doseDiaryEntryId = await dummyDb.createDosageEntry(datetime);
      doseId = await dummyDb.createDose(
        doseDiaryEntryId,
        doseMedicineId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should delete a dose', async () => {
      const deleteDose = gql(`
        mutation DeleteDose($input: DeleteDoseInput!) {
        deleteDose(input: $input) {
          id
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(deleteDose, {
          input: {
            id: doseId,
            expectedVersion: 1,
          },
        })
      );
      const data = result.data.deleteDose;
      expect(data.id).to.equal(doseId);
    });
  });

  describe('updateDose', () => {
    const datetime = '2019-07-02T12:43:00Z';
    let doseMedicineId;
    let doseDiaryEntryId;
    let doseId;
    const medicineName = 'Camphor Oil';
    const quantity = {
      amount: 1.5,
      unit: 'Tbps',
    };

    before('create a dose', async () => {
      doseMedicineId = await dummyDb.createMedicine(medicineName);
      doseDiaryEntryId = await dummyDb.createDosageEntry(datetime);
      doseId = await dummyDb.createDose(
        doseDiaryEntryId,
        doseMedicineId,
        quantity.amount,
        quantity.unit
      );
    });

    it('should update a dose', async () => {
      const updateDose = gql(`
        mutation UpdateDose($input: UpdateDoseInput!) {
        updateDose(input: $input) {
          id
          quantity { amount }
          version
        }
        }`);

      const newAmount = 3.5;

      const result = await API.graphql(
        graphqlOperation(updateDose, {
          input: {
            id: doseId,
            expectedVersion: 1,
            quantity: {
              amount: newAmount,
            },
          },
        })
      );
      const data = result.data.updateDose;
      expect(data.quantity.amount).to.equal(newAmount);
      expect(data.version).to.equal(2);
    });
  });
});
