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

  describe('createDiaryEntry', () => {
    it('should create a meal entry', async () => {
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
            nameId
            entryId
            meal { ingredients { entryId }}
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation,
        variables: {
          input: {
            userId,
            creationDate: datetime,
            modificationDate: datetime,
            datetime,
            meal: {
              ingredients: [],
            },
          },
        },
      });
      const data = result.data.createDiaryEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.meal.ingredients).to.be.array();
    });

    it('should create a bowel movement entry', async () => {
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
            nameId
            entryId
            bowelMovement { volume }
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation,
        variables: {
          input: {
            userId,
            creationDate: datetime,
            modificationDate: datetime,
            datetime,
            bowelMovement: {
              type: 3,
              volume: 4,
            },
          },
        },
      });
      const data = result.data.createDiaryEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.bowelMovement.volume).to.equal(4);
    });
  });

  describe('createMealEntry', () => {
    it('should create a meal entry', async () => {
      const creationDatetime = '2019-07-02T12:40:00Z';
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateMealEntry($input: CreateMealEntryInput!) {
        createMealEntry(input: $input) {
            nameId
            entryId
            creationDate
            modificationDate
            datetime
            meal { ingredients { entryId }}
        }
        }`);

      await client.hydrated();
      const result = await client.mutate({
        mutation,
        variables: {
          input: {
            userId,
            creationDate: creationDatetime,
            datetime,
          },
        },
      });
      const data = result.data.createMealEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.meal.ingredients).to.be.array();
      expect(data.meal.ingredients.length).to.equal(0);
      expect(data.datetime).to.equal(datetime);
      expect(data.creationDate).to.equal(creationDatetime);
      expect(data.modificationDate).to.equal(data.creationDate);
    });
  });

  describe('getDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    before('create a diary entry', async () => {
      id = await dummyDb.createMealEntry(userId, datetime);
    });

    it('should get a diary entry', async () => {
      const getDiaryEntry = gql(`
        query getDiaryEntry($nameId: String!, $entryId: String!) {
        getDiaryEntry(nameId: $nameId, entryId: $entryId) {
            nameId
            entryId
        }
        }`);

      const getResult = await client.query({
        query: getDiaryEntry,
        variables: id,
      });
      const getData = getResult.data.getDiaryEntry;
      expect(getData.__typename).to.equal('DiaryEntry');
    });
  });

  describe('deleteDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    beforeEach('create a diary entry', async () => {
      id = await dummyDb.createMealEntry(userId, datetime);
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
          input: id,
        },
      });
      const data = result.data.deleteDiaryEntry;
      expect(data.__typename).to.equal('DiaryEntry');
      expect(data.nameId).to.equal(id.nameId);
      expect(data.entryId).to.equal(id.entryId);
    });
  });

  describe('updateDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    beforeEach('create a diary entry', async () => {
      id = await dummyDb.createMealEntry(userId, datetime);
    });

    it('should update a diary entry', async () => {
      const updateDiaryEntry = gql(`
        mutation UpdateDiaryEntry($input: UpdateDiaryEntryInput!) {
        updateDiaryEntry(input: $input) {
            nameId
            entryId
            datetime
        }
        }`);

      const newDatetime = '2019-08-02T12:43:00Z';
      const result = await client.mutate({
        mutation: updateDiaryEntry,
        variables: {
          input: {
            nameId: id.nameId,
            entryId: id.entryId,
            datetime: newDatetime,
          },
        },
      });
      const data = result.data.updateDiaryEntry;
      expect(data.datetime).to.equal(newDatetime);
    });
  });

  after('clear diaryentry database', dummyDb.clearItems);
});
