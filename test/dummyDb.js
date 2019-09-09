const { API, graphqlOperation } = require('aws-amplify');
const gql = require('graphql-tag');
const { config } = require('./aws-setup');

API.configure(config);

let createdIds = [];

const createDose = async (userId, dosageEntryId, medicineId, amount, unit) => {
  const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        userId,
        dosageEntryId,
        medicineId,
        quantity: { amount, unit },
      },
    })
  );
  const createData = createResult.data.createDose;
  createdIds.push(createData);
  return createData.id;
};

const createFood = async name => {
  const mutation = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: { name },
    })
  );
  const createData = createResult.data.createFood;
  createdIds.push(createData);
  return createData.id;
};

const createIngredient = async (userId, mealEntryId, foodId, amount, unit) => {
  const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        userId,
        mealEntryId,
        foodId,
        quantity: { amount, unit },
      },
    })
  );
  const createData = createResult.data.createIngredient;
  createdIds.push(createData);
  return createData.id;
};

const createDosageEntry = async (userId, datetime) => {
  const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        userId,
        creationDate: datetime,
        modificationDate: datetime,
        datetime,
        dosage: {
          doses: [],
        },
      },
    })
  );
  const createData = createResult.data.createDiaryEntry;
  createdIds.push(createData);
  return createData.id;
};

const createMealEntry = async (userId, datetime) => {
  const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        userId,
        creationDate: datetime,
        modificationDate: datetime,
        datetime,
        meal: {
          ingredients: [],
        },
      },
    })
  );
  const createData = createResult.data.createDiaryEntry;
  createdIds.push(createData);
  return createData.id;
};

const createMedicine = async name => {
  const mutation = gql(`
        mutation CreateMedicine($input: CreateMedicineInput!) {
        createMedicine(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: { name },
    })
  );
  const createData = createResult.data.createMedicine;
  createdIds.push(createData);
  return createData.id;
};

const deleteItem = async (id, entryId) => {
  const mutation = gql(`
        mutation DeleteItem($input: GutAiIdInput!) {
        deleteItem(input: $input) {
          id
        }
        }`);

  const result = await API.graphql(
    graphqlOperation(mutation, {
      input: { id, entryId },
    })
  );
  const deletedItem = result.data.deleteItem;
  createdIds = createdIds.filter(x => x.id !== deletedItem.id);
};

const clearItems = async () => {
  const mutation = gql(`
        mutation DeleteItem($input: GutAiIdInput!) {
        deleteItem(input: $input) {
          id
        }
        }`);

  createdIds.forEach(async id => {
    API.graphql(
      graphqlOperation(mutation, {
        input: {
          id: id.id,
          entryId: id.entryId,
        },
      })
    );
  });
  createdIds = [];
};

module.exports = {
  createDose,
  createDosageEntry,
  createFood,
  createIngredient,
  createMealEntry,
  createMedicine,
  deleteItem,
  clearItems,
};
