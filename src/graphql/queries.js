/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const getFood = `query GetFood($id: ID!) {
  getFood(id: $id) {
    id
    name
  }
}
`;
export const listFoods = `query ListFoods(
  $filter: ModelFoodFilterInput
  $limit: Int
  $nextToken: String
) {
  listFoods(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      name
    }
    nextToken
  }
}
`;
export const getIngredient = `query GetIngredient($id: ID!) {
  getIngredient(id: $id) {
    id
    food {
      id
      name
    }
    quantity {
      amount
      unit
    }
  }
}
`;
export const listIngredients = `query ListIngredients(
  $filter: ModelIngredientFilterInput
  $limit: Int
  $nextToken: String
) {
  listIngredients(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      food {
        id
        name
      }
      quantity {
        amount
        unit
      }
    }
    nextToken
  }
}
`;
export const getMedicine = `query GetMedicine($id: ID!) {
  getMedicine(id: $id) {
    id
    name
  }
}
`;
export const listMedicines = `query ListMedicines(
  $filter: ModelMedicineFilterInput
  $limit: Int
  $nextToken: String
) {
  listMedicines(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      name
    }
    nextToken
  }
}
`;
