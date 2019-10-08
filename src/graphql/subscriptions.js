/* eslint-disable */
// this is an auto generated file. This will be overwritten

export const onCreateFood = `subscription OnCreateFood {
  onCreateFood {
    id
    name
  }
}
`;
export const onUpdateFood = `subscription OnUpdateFood {
  onUpdateFood {
    id
    name
  }
}
`;
export const onDeleteFood = `subscription OnDeleteFood {
  onDeleteFood {
    id
    name
  }
}
`;
export const onCreateIngredient = `subscription OnCreateIngredient($owner: String!) {
  onCreateIngredient(owner: $owner) {
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
export const onUpdateIngredient = `subscription OnUpdateIngredient($owner: String!) {
  onUpdateIngredient(owner: $owner) {
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
export const onDeleteIngredient = `subscription OnDeleteIngredient($owner: String!) {
  onDeleteIngredient(owner: $owner) {
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
export const onCreateMedicine = `subscription OnCreateMedicine {
  onCreateMedicine {
    id
    name
  }
}
`;
export const onUpdateMedicine = `subscription OnUpdateMedicine {
  onUpdateMedicine {
    id
    name
  }
}
`;
export const onDeleteMedicine = `subscription OnDeleteMedicine {
  onDeleteMedicine {
    id
    name
  }
}
`;
export const onCreateDose = `subscription OnCreateDose($owner: String!) {
  onCreateDose(owner: $owner) {
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
export const onUpdateDose = `subscription OnUpdateDose($owner: String!) {
  onUpdateDose(owner: $owner) {
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
export const onDeleteDose = `subscription OnDeleteDose($owner: String!) {
  onDeleteDose(owner: $owner) {
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
export const onCreateDiaryEntry = `subscription OnCreateDiaryEntry($owner: String!) {
  onCreateDiaryEntry(owner: $owner) {
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
export const onUpdateDiaryEntry = `subscription OnUpdateDiaryEntry($owner: String!) {
  onUpdateDiaryEntry(owner: $owner) {
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
export const onDeleteDiaryEntry = `subscription OnDeleteDiaryEntry($owner: String!) {
  onDeleteDiaryEntry(owner: $owner) {
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
