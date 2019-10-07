/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const createMealEntry = `mutation CreateMealEntry($input: CreateMealEntryInput!) {
  createMealEntry(input: $input) {
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
export const createDosageEntry = `mutation CreateDosageEntry($input: CreateDosageEntryInput!) {
  createDosageEntry(input: $input) {
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
export const createSymptomEntry = `mutation CreateSymptomEntry($input: CreateSymptomEntryInput!) {
  createSymptomEntry(input: $input) {
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
export const createBowelMovementEntry = `mutation CreateBowelMovementEntry($input: CreateBowelMovementEntryInput!) {
  createBowelMovementEntry(input: $input) {
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
export const createDiaryEntry = `mutation CreateDiaryEntry($input: CreateDiaryEntryInput!) {
  createDiaryEntry(input: $input) {
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
export const updateDiaryEntry = `mutation UpdateDiaryEntry($input: UpdateDiaryEntryInput!) {
  updateDiaryEntry(input: $input) {
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
export const deleteDiaryEntry = `mutation DeleteDiaryEntry($input: DeleteDiaryEntryInput!) {
  deleteDiaryEntry(input: $input) {
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
