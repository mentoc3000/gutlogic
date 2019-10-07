const { API, graphqlOperation } = require('aws-amplify');
const chai = require('chai');
const gql = require('graphql-tag');
const assertArrays = require('chai-arrays');
const { config, signIn, signOut } = require('./aws-setup');
const dummyDb = require('./dummyDb');

API.configure(config);

chai.use(assertArrays);
const { expect } = chai;

describe('DiaryEntry database', function diaryEntryTests() {
  this.timeout(5000);
  before('Sign in', signIn);
  after('Sign out', async () => {
    await dummyDb.clearItems();
    await signOut();
  });
  describe('listDiaryEntries', () => {
    it('should get all diary entries', async () => {
      const query = gql(`
        query ListDiaryEntries {
        listDiaryEntries {
            items {
              id
            }
        }
        }`);

      const result = await API.graphql(graphqlOperation(query));
      const data = result.data.listDiaryEntries;
      expect(data.items).to.be.array();
    });
  });

  describe('createDiaryEntry', () => {
    it('should create a meal entry', async () => {
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
          type
          ingredients { items { id } }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            type: 'MEAL',
            createdAt: datetime,
            updatedAt: datetime,
            datetime,
          },
        })
      );
      const data = result.data.createDiaryEntry;
      expect(data.type).to.equal('MEAL');
      expect(data.ingredients.items).to.be.array();
      expect(data.ingredients.items.length).to.equal(0);
    });

    it('should create a bowel movement entry', async () => {
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
          type
          bowelMovement { volume }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            type: 'BOWELMOVEMENT',
            createdAt: datetime,
            updatedAt: datetime,
            datetime,
            bowelMovement: {
              type: 3,
              volume: 4,
            },
          },
        })
      );
      const data = result.data.createDiaryEntry;
      expect(data.type).to.equal('BOWELMOVEMENT');
      expect(data.bowelMovement.volume).to.equal(4);
    });
  });

  describe('createMealEntry', () => {
    it('should create a meal entry', async () => {
      const createdAtTime = '2019-07-02T12:40:00Z';
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateMealEntry($input: CreateMealEntryInput!) {
        createMealEntry(input: $input) {
          id
          type
          createdAt
          updatedAt
          datetime
          ingredients { items { id } }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            createdAt: createdAtTime,
            datetime,
          },
        })
      );
      const data = result.data.createMealEntry;
      expect(data.type).to.equal('MEAL');
      expect(data.ingredients.items).to.be.array();
      expect(data.ingredients.items.length).to.equal(0);
      expect(data.datetime).to.equal(datetime);
      expect(data.createdAt).to.equal(createdAtTime);
    });
  });

  describe('createBowelMovementEntry', () => {
    it('should create a bowel movement entry', async () => {
      const createdAtTime = '2019-07-02T12:40:00Z';
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateBowelMovementEntry($input: CreateBowelMovementEntryInput!) {
        createBowelMovementEntry(input: $input) {
          id
          type
          createdAt
          updatedAt
          datetime
          bowelMovement { type, volume }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            createdAt: createdAtTime,
            datetime,
            bowelMovement: {
              type: 3,
              volume: 4,
            },
          },
        })
      );
      const data = result.data.createBowelMovementEntry;
      expect(data.type).to.equal('BOWELMOVEMENT');
      expect(data.bowelMovement.type).to.equal(3);
      expect(data.bowelMovement.volume).to.equal(4);
      expect(data.datetime).to.equal(datetime);
      expect(data.createdAt).to.equal(createdAtTime);
    });
  });

  describe('createDosageEntry', () => {
    it('should create a dosage entry', async () => {
      const createdAtTime = '2019-07-02T12:40:00Z';
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateDosageEntry($input: CreateDosageEntryInput!) {
        createDosageEntry(input: $input) {
          id
          type
          createdAt
          updatedAt
          datetime
          doses { items { medicine { name } } }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            createdAt: createdAtTime,
            datetime,
          },
        })
      );
      const data = result.data.createDosageEntry;
      expect(data.type).to.equal('DOSAGE');
      expect(data.doses.items).to.be.array();
      expect(data.doses.items.length).to.equal(0);
      expect(data.datetime).to.equal(datetime);
      expect(data.createdAt).to.equal(createdAtTime);
    });
  });

  describe('createSymptomEntry', () => {
    it('should create a symptom entry', async () => {
      const createdAtTime = '2019-07-02T12:40:00Z';
      const datetime = '2019-07-02T12:43:00Z';
      const mutation = gql(`
        mutation CreateSymptomEntry($input: CreateSymptomEntryInput!) {
        createSymptomEntry(input: $input) {
          id
          type
          createdAt
          updatedAt
          datetime
          symptom { 
            symptomType
            severity
            }
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(mutation, {
          input: {
            createdAt: createdAtTime,
            datetime,
            symptom: {
              symptomType: 'Gas',
              severity: 4.3,
            },
          },
        })
      );
      const data = result.data.createSymptomEntry;
      expect(data.type).to.equal('SYMPTOM');
      expect(data.datetime).to.equal(datetime);
      expect(data.createdAt).to.equal(createdAtTime);
      expect(data.symptom.symptomType).to.equal('Gas');
      expect(data.symptom.severity).to.equal(4.3);
    });
  });

  describe('getDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    before('create a diary entry', async () => {
      id = await dummyDb.createMealEntry(datetime);
    });

    it('should get a diary entry', async () => {
      const getDiaryEntry = gql(`
        query getDiaryEntry($id: ID!) {
        getDiaryEntry(id: $id) {
          id
          type
        }
        }`);

      const getResult = await API.graphql(
        graphqlOperation(getDiaryEntry, { id })
      );
      const getData = getResult.data.getDiaryEntry;
      expect(getData.type).to.equal('MEAL');
    });
  });

  describe('deleteDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    beforeEach('create a diary entry', async () => {
      id = await dummyDb.createMealEntry(datetime);
    });

    it('should delete a diary entry', async () => {
      const deleteDiaryEntry = gql(`
        mutation DeleteDiaryEntry($input: DeleteDiaryEntryInput!) {
        deleteDiaryEntry(input: $input) {
          id
        }
        }`);

      const result = await API.graphql(
        graphqlOperation(deleteDiaryEntry, {
          input: {
            id,
            expectedVersion: 1,
          },
        })
      );
      const data = result.data.deleteDiaryEntry;
      expect(data.id).to.equal(id);
    });
  });

  describe('updateDiaryEntry', () => {
    let id;
    const datetime = '2019-07-02T12:43:00Z';

    beforeEach('create a meal entry', async () => {
      id = await dummyDb.createMealEntry(datetime);
    });

    it('should update a meal entry', async () => {
      const updateDiaryEntry = gql(`
        mutation UpdateDiaryEntry($input: UpdateDiaryEntryInput!) {
        updateDiaryEntry(input: $input) {
          id
          version
          updatedAt
          datetime
        }
        }`);

      const newDatetime = '2019-08-02T12:43:00Z';
      const result = await API.graphql(
        graphqlOperation(updateDiaryEntry, {
          input: {
            id,
            expectedVersion: 1,
            datetime: newDatetime,
            updatedAt: newDatetime,
          },
        })
      );
      const data = result.data.updateDiaryEntry;
      expect(data.datetime).to.equal(newDatetime);
      expect(data.updatedAt).to.equal(newDatetime);
      expect(data.version).to.equal(2);
    });
  });
});
