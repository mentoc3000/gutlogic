const { API, graphqlOperation } = require('aws-amplify');
const gql = require('graphql-tag');
const { config } = require('./aws-setup');

API.configure(config);

let createdItems = [];

const createDose = async (doseMedicineId, amount, unit) => {
  const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        doseMedicineId,
        quantity: { amount, unit },
      },
    })
  );
  const createData = createResult.data.createDose;
  createdItems.push({
    type: 'Dose',
    id: createData.id,
  });
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
  createdItems.push({
    type: 'Food',
    id: createData.id,
  });
  return createData.id;
};

const createIngredient = async (ingredientFoodId, amount, unit) => {
  const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        ingredientFoodId,
        quantity: { amount, unit },
      },
    })
  );
  const createData = createResult.data.createIngredient;
  createdItems.push({
    type: 'Ingredient',
    id: createData.id,
  });
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
  createdItems.push({
    type: 'DiaryEntry',
    id: createData.id,
  });
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
  createdItems.push({
    type: 'DiaryEntry',
    id: createData.id,
  });
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
  createdItems.push({
    type: 'Medicine',
    id: createData.id,
  });
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
  createdItems = createdItems.filter(x => x.id !== deletedItem.id);
};

const clearItems = async () => {
  createdItems.forEach(async item => {
    const mutation = gql(`
          mutation Delete${item.type}($input: Delete${item.type}Input!) {
          delete${item.type}(input: $input) {
            id
          }
          }`);
    API.graphql(
      graphqlOperation(mutation, {
        input: { id: item.id },
      })
    );
  });
  createdItems = [];
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
