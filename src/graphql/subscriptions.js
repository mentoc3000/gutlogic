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
export const onCreateIngredient = `subscription OnCreateIngredient {
  onCreateIngredient {
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
export const onUpdateIngredient = `subscription OnUpdateIngredient {
  onUpdateIngredient {
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
export const onDeleteIngredient = `subscription OnDeleteIngredient {
  onDeleteIngredient {
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
export const onCreateDose = `subscription OnCreateDose {
  onCreateDose {
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
export const onUpdateDose = `subscription OnUpdateDose {
  onUpdateDose {
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
export const onDeleteDose = `subscription OnDeleteDose {
  onDeleteDose {
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
export const onCreateDiaryEntry = `subscription OnCreateDiaryEntry {
  onCreateDiaryEntry {
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
export const onUpdateDiaryEntry = `subscription OnUpdateDiaryEntry {
  onUpdateDiaryEntry {
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
export const onDeleteDiaryEntry = `subscription OnDeleteDiaryEntry {
  onDeleteDiaryEntry {
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
