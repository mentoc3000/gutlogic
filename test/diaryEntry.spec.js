const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { client } = require('./aws-exports');
const dummyDb = require('./dummyDb');

chai.use(assertArrays);
const { expect } = chai;

describe('DiaryEntry database', () => {
  const userId = 'fakeuserid';

  describe('listDiaryEntries', () => {
    it('should get all diary entries', async () => {
      const query = gql(`
        query ListDiaryEntries($userId: String!) {
        listDiaryEntries(userId: $userId) {
            items {
                nameId
                entryId
            }
        }
        }`);

      await client.hydrated();
      const result = await client.query({
        query,
        variables: { userId },
      });
      const data = result.data.listDiaryEntries;
      expect(data.__typename).to.equal('PaginatedDiaryEntries');
      expect(data.items).to.be.array();
    });
  });

  describe.skip('createDiaryEntry', () => {
    it('should create a diary entry', async () => {
      const quantity = {
        amount: 0.3,
        unit: 'each',
      };
      const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
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
      const data = result.data.createDiaryEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  describe.skip('getDiaryEntry', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    before('create a diary entry', async () => {
      [nameId, entryId] = await dummyDb.createDiaryEntry(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should get a diary entry', async () => {
      const getDiaryEntry = gql(`
        query getDiaryEntry($nameId: String!, $entryId: String!) {
        getDiaryEntry(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
            quantity { amount, unit }
        }
        }`);

      const getResult = await client.query({
        query: getDiaryEntry,
        variables: { nameId, entryId },
      });
      const getData = getResult.data.getDiaryEntry;
      expect(getData.__typename).to.equal('DiaryEntry');
      expect(getData.quantity.amount).to.equal(amount);
      expect(getData.quantity.unit).to.equal(unit);
    });
  });

  describe.skip('deleteDiaryEntry', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a diary entry', async () => {
      [nameId, entryId] = await dummyDb.createDiaryEntry(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should delete a diary entry', async () => {
      const deleteDiaryEntry = gql(`
        mutation DeleteDiaryEntry($input: GutAiIdInput!) {
        deleteDiaryEntry(input: $input) {
            nameId
            entryId
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation: deleteDiaryEntry,
        variables: {
          input: { nameId, entryId },
        },
      });
      const data = result.data.deleteDiaryEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.nameId).to.equal(nameId);
      expect(data.entryId).to.equal(entryId);
    });
  });

  describe.skip('updateDiaryEntry', () => {
    let nameId;
    let entryId;
    const amount = 2.4;
    const unit = 'cups';

    beforeEach('create a diary entry', async () => {
      [nameId, entryId] = await dummyDb.createDiaryEntry(
        userId,
        mealEntryId,
        foodId,
        amount,
        unit
      );
    });

    it('should update a diary entry', async () => {
      const updateDiaryEntry = gql(`
        mutation UpdateDiaryEntry($input: UpdateDiaryEntryInput!) {
        updateDiaryEntry(input: $input) {
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
        mutation: updateDiaryEntry,
        variables: {
          input: { nameId, entryId, quantity },
        },
      });
      const data = result.data.updateDiaryEntry;
      expect(data.quantity.amount).to.equal(quantity.amount);
      expect(data.quantity.unit).to.equal(quantity.unit);
    });
  });

  after('clear diaryentry database', dummyDb.clearItems);
});
