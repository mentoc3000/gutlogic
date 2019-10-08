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
    diaryEntry {
      id
      type
      createdAt
      updatedAt
      datetime
      ingredients {
        nextToken
      }
      bowelMovement {
        type
        volume
      }
      doses {
        nextToken
      }
      symptom {
        symptomType
        severity
      }
      notes
      version
      owner
    }
    version
    owner
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
      diaryEntry {
        id
        type
        createdAt
        updatedAt
        datetime
        notes
        version
        owner
      }
      version
      owner
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
export const getDose = `query GetDose($id: ID!) {
  getDose(id: $id) {
    id
    medicine {
      id
      name
    }
    quantity {
      amount
      unit
    }
    diaryEntry {
      id
      type
      createdAt
      updatedAt
      datetime
      ingredients {
        nextToken
      }
      bowelMovement {
        type
        volume
      }
      doses {
        nextToken
      }
      symptom {
        symptomType
        severity
      }
      notes
      version
      owner
    }
    version
    owner
  }
}
`;
export const listDoses = `query ListDoses(
  $filter: ModelDoseFilterInput
  $limit: Int
  $nextToken: String
) {
  listDoses(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      medicine {
        id
        name
      }
      quantity {
        amount
        unit
      }
      diaryEntry {
        id
        type
        createdAt
        updatedAt
        datetime
        notes
        version
        owner
      }
      version
      owner
    }
    nextToken
  }
}
`;
export const getDiaryEntry = `query GetDiaryEntry($id: ID!) {
  getDiaryEntry(id: $id) {
    id
    type
    createdAt
    updatedAt
    datetime
    ingredients {
      items {
        id
        version
        owner
      }
      nextToken
    }
    bowelMovement {
      type
      volume
    }
    doses {
      items {
        id
        version
        owner
      }
      nextToken
    }
    symptom {
      symptomType
      severity
    }
    notes
    version
    owner
  }
}
`;
export const listDiaryEntries = `query ListDiaryEntries(
  $filter: ModelDiaryEntryFilterInput
  $limit: Int
  $nextToken: String
) {
  listDiaryEntries(filter: $filter, limit: $limit, nextToken: $nextToken) {
    items {
      id
      type
      createdAt
      updatedAt
      datetime
      ingredients {
        nextToken
      }
      bowelMovement {
        type
        volume
      }
      doses {
        nextToken
      }
      symptom {
        symptomType
        severity
      }
      notes
      version
      owner
    }
    nextToken
  }
}
`;
