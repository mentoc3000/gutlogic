import '../models/food.dart';
import '../models/diary_entry.dart';
import '../models/dose.dart';
import '../models/bowel_movement.dart';
import '../models/medicine.dart';
import '../models/meal.dart';
import '../models/ingredient.dart';
import '../models/quantity.dart';
import '../models/symptom.dart';

class Dummy {
  static final _artichoke = Food(
    name: 'Artichoke', 
    irritants: ['Fructans', 'Fructose']
  );
  static final _creamCheese = Food(
    name: 'Cream Cheese', 
    irritants: ['Lactose']
  );
  static final _egg = Food(
    name: 'Egg', 
    irritants: []
  );

  static final foodList = [_artichoke, _creamCheese, _egg];

  static List<MealEntry> mealEntries = [
    MealEntry(
      dateTime: DateTime(2019, 2, 7, 8, 14), 
      meal: Meal(
        name: "Breakfast",
        ingredients: [
          Ingredient(
            food: Food(name: "Bread", irritants: ['Fructans']),
            quantity: Quantity(amount: 1.5, unit: "slices")
          ),
          Ingredient(
            food: Food(name: "Egg", irritants: []),
            quantity: Quantity(amount: 1, unit: "each")
          )
        ]
      )
    ),
  ];

  static List<BowelMovementEntry> bowelMovementEntries = [
    BowelMovementEntry(
      dateTime: DateTime(2019, 2, 7, 11, 31),
      bowelMovement: BowelMovement(type: 4, volume: 2),
    )
  ];

  static List<SymptomEntry> symptomEntries = [
    SymptomEntry(
      dateTime: DateTime(2019, 2, 7, 15, 31),
      symptom: Symptom(symptomType: SymptomType.bloating, severity: 6),
    )
  ];

  static List<DosesEntry> dosesEntries = [
    DosesEntry(
      dateTime: DateTime(2019, 2, 7, 12, 0),
      doses: [
        Dose(
          medicine: Medicine(name: "Pro-8"),
          quantity: Quantity(amount: 1, unit: 'pill')
        ),
        Dose(
          medicine: Medicine(name: "Fiber"),
          quantity: Quantity(amount: 2, unit: 'Tbsp')
        )
      ]
    )
  ];
}