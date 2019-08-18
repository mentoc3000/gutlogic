const gql = require('graphql-tag');
const { client } = require('./aws-exports');

let createdIds = [];

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
  createdIds.push(createData);
  return {
    nameId: createData.nameId,
    entryId: createData.entryId,
  };
};

const createFood = async name => {
  const mutation = gql(`
        mutation CreateFood($input: CreateFoodInput!) {
        createFood(input: $input) {
            nameId
            entryId
        }
        }`);

  await client.hydrated();
  const createResult = await client.mutate({
    mutation,
    variables: {
      input: { name },
    },
  });
  const createData = createResult.data.createFood;
  createdIds.push(createData);
  return {
    nameId: createData.nameId,
    entryId: createData.entryId,
  };
};

const createIngredient = async (userId, mealEntryId, foodId, amount, unit) => {
  const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
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
        mealEntryId,
        foodId,
        quantity: { amount, unit },
      },
    },
  });
  const createData = createResult.data.createIngredient;
  createdIds.push(createData);
  return {
    nameId: createData.nameId,
    entryId: createData.entryId,
  };
};

const createMealEntry = async (userId, datetime) => {
  const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
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
        creationDate: datetime,
        modificationDate: datetime,
        datetime,
        meal: {
          ingredients: [],
        },
      },
    },
  });
  const createData = createResult.data.createDiaryEntry;
  createdIds.push(createData);
  return {
    nameId: createData.nameId,
    entryId: createData.entryId,
  };
};

const createMedicine = async name => {
  const mutation = gql(`
        mutation CreateMedicine($input: CreateMedicineInput!) {
        createMedicine(input: $input) {
            nameId
            entryId
        }
        }`);

  await client.hydrated();
  const createResult = await client.mutate({
    mutation,
    variables: {
      input: { name },
    },
  });
  const createData = createResult.data.createMedicine;
  createdIds.push(createData);
  return {
    nameId: createData.nameId,
    entryId: createData.entryId,
  };
};

const deleteItem = async (nameId, entryId) => {
  const mutation = gql(`
        mutation DeleteItem($input: GutAiIdInput!) {
        deleteItem(input: $input) {
            nameId
            entryId
        }
        }`);

  await client.hydrated();
  const result = await client.mutate({
    mutation,
    variables: {
      input: { nameId, entryId },
    },
  });
  const id = result.data.deleteItem;
  createdIds = createdIds.filter(
    x => x.nameId !== id.nameId && x.entryId !== id.entryId
  );
};

const clearItems = async () => {
  const mutation = gql(`
        mutation DeleteItem($input: GutAiIdInput!) {
        deleteItem(input: $input) {
            nameId
            entryId
        }
        }`);

  await client.hydrated();
  createdIds.forEach(async id => {
    client.mutate({
      mutation,
      variables: {
        input: {
          nameId: id.nameId,
          entryId: id.entryId,
        },
      },
    });
  });
  createdIds = [];
};

module.exports = {
  createDose,
  createFood,
  createIngredient,
  createMealEntry,
  createMedicine,
  deleteItem,
  clearItems,
};
