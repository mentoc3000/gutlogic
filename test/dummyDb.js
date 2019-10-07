const { API, graphqlOperation } = require('aws-amplify');
const gql = require('graphql-tag');
const { config } = require('./aws-setup');

API.configure(config);

let createdItems = [];

const createDose = async (doseDiaryEntryId, doseMedicineId, amount, unit) => {
  const mutation = gql(`
        mutation CreateDose($input: CreateDoseInput!) {
        createDose(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        doseDiaryEntryId,
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

const createIngredient = async (
  ingredientDiaryEntryId,
  ingredientFoodId,
  amount,
  unit
) => {
  const mutation = gql(`
        mutation CreateIngredient($input: CreateIngredientInput!) {
        createIngredient(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        ingredientDiaryEntryId,
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

const createDosageEntry = async datetime => {
  const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        type: 'DOSAGE',
        createdAt: datetime,
        updatedAt: datetime,
        datetime,
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

const createMealEntry = async datetime => {
  const mutation = gql(`
        mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
        createDiaryEntry(input: $input) {
          id
        }
        }`);

  const createResult = await API.graphql(
    graphqlOperation(mutation, {
      input: {
        type: 'MEAL',
        createdAt: datetime,
        updatedAt: datetime,
        datetime,
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

const versionedTypes = ['Ingredient', 'Dose', 'DiaryEntry'];

const clearItems = async () => {
  // createdItems.forEach(async item => {
  for (let index = 0; index < createdItems.length; index++) {
    const item = createdItems[index];
    let input;
    if (versionedTypes.includes(item.type)) {
      // Add version to mutation input if necessary
      const query = gql(`
        query Get${item.type}($id: ID!) {
          get${item.type}(id: $id) {
            version
          }
        }`);
      const result = await API.graphql(
        graphqlOperation(query, { id: item.id })
      );
      const info = result.data[`get${item.type}`];
      if (info == null) {
        // item has already been deleted
        break;
      }
      input = {
        id: item.id,
        expectedVersion: info.version,
      };
    } else {
      input = { id: item.id };
    }
    const mutation = gql(`
      mutation Delete${item.type}($input: Delete${item.type}Input!) {
      delete${item.type}(input: $input) {
        id
      }
      }`);
    await API.graphql(graphqlOperation(mutation, { input }));
  }
  createdItems = [];
};

module.exports = {
  createDose,
  createDosageEntry,
  createFood,
  createIngredient,
  createMealEntry,
  createMedicine,
  clearItems,
};
