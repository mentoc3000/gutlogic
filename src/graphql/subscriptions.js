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
