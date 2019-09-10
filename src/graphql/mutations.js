/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const createFood = `mutation CreateFood($input: CreateFoodInput!) {
  createFood(input: $input) {
    id
    name
  }
}
`;
export const updateFood = `mutation UpdateFood($input: UpdateFoodInput!) {
  updateFood(input: $input) {
    id
    name
  }
}
`;
export const deleteFood = `mutation DeleteFood($input: DeleteFoodInput!) {
  deleteFood(input: $input) {
    id
    name
  }
}
`;
export const createIngredient = `mutation CreateIngredient($input: CreateIngredientInput!) {
  createIngredient(input: $input) {
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
export const updateIngredient = `mutation UpdateIngredient($input: UpdateIngredientInput!) {
  updateIngredient(input: $input) {
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
export const deleteIngredient = `mutation DeleteIngredient($input: DeleteIngredientInput!) {
  deleteIngredient(input: $input) {
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
export const createMedicine = `mutation CreateMedicine($input: CreateMedicineInput!) {
  createMedicine(input: $input) {
    id
    name
  }
}
`;
export const updateMedicine = `mutation UpdateMedicine($input: UpdateMedicineInput!) {
  updateMedicine(input: $input) {
    id
    name
  }
}
`;
export const deleteMedicine = `mutation DeleteMedicine($input: DeleteMedicineInput!) {
  deleteMedicine(input: $input) {
    id
    name
  }
}
`;
export const createDose = `mutation CreateDose($input: CreateDoseInput!) {
  createDose(input: $input) {
    id
    medicine {
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
export const updateDose = `mutation UpdateDose($input: UpdateDoseInput!) {
  updateDose(input: $input) {
    id
    medicine {
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
export const deleteDose = `mutation DeleteDose($input: DeleteDoseInput!) {
  deleteDose(input: $input) {
    id
    medicine {
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
export const createDiaryEntry = `mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
  createDiaryEntry(input: $input) {
    id
    type
    creationDate
    modificationDate
    datetime
    ingredients {
      items {
        id
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
      }
      nextToken
    }
    symptom {
      symptomType
      severity
    }
    notes
  }
}
`;
export const updateDiaryEntry = `mutation UpdateDiaryEntry($input: UpdateDiaryEntryInput!) {
  updateDiaryEntry(input: $input) {
    id
    type
    creationDate
    modificationDate
    datetime
    ingredients {
      items {
        id
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
      }
      nextToken
    }
    symptom {
      symptomType
      severity
    }
    notes
  }
}
`;
export const deleteDiaryEntry = `mutation DeleteDiaryEntry($input: DeleteDiaryEntryInput!) {
  deleteDiaryEntry(input: $input) {
    id
    type
    creationDate
    modificationDate
    datetime
    ingredients {
      items {
        id
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
      }
      nextToken
    }
    symptom {
      symptomType
      severity
    }
    notes
  }
}
`;
