import 'package:built_collection/built_collection.dart';

import '../models/bowel_movement.dart';
import '../models/diary_entry.dart';
import '../models/dosage.dart';
import '../models/dose.dart';
import '../models/food.dart';
import '../models/ingredient.dart';
import '../models/irritant.dart';
import '../models/meal.dart';
import '../models/medicine.dart';
import '../models/quantity.dart';
import '../models/symptom_type.dart';
import '../models/symptom.dart';

class Dummy {
  static final _artichoke = Food(
    name: 'Artichoke',
    irritants: BuiltList<Irritant>([
      Irritant(name: 'Fructans'),
      Irritant(name: 'Fructose'),
    ]),
  );
  static final _creamCheese = Food(
    name: 'Cream Cheese',
    irritants: BuiltList<Irritant>([
      Irritant(name: 'Lactose'),
    ]),
  );
  static final _egg = Food(name: 'Egg', irritants: BuiltList<Irritant>([]));

  static final foodList = [_artichoke, _creamCheese, _egg];

  static List<MealEntry> mealEntries = [
    MealEntry(
      id: 'Dummy001',
      userId: 'jp.sheehan2@gmail.com',
      creationDate: DateTime(2019, 2, 7, 8, 14),
      modificationDate: DateTime(2019, 2, 7, 8, 14),
      dateTime: DateTime(2019, 2, 7, 8, 14),
      meal: Meal(
        ingredients: BuiltList<Ingredient>([
          Ingredient(
              food: Food(
                  name: "Bread",
                  irritants: BuiltList<Irritant>([Irritant(name: 'Fructans')])),
              quantity: Quantity(amount: 1.5, unit: "slices")),
          Ingredient(
              food: Food(name: "Egg", irritants: BuiltList<Irritant>([])),
              quantity: Quantity(amount: 1, unit: "each")),
          Ingredient(
              food: Food(
                  name: "Orange Juice", irritants: BuiltList<Irritant>([])),
              quantity: Quantity(amount: 8, unit: "oz"))
        ]),
      ),
      notes: '',
    ),
  ];

  static List<BowelMovementEntry> bowelMovementEntries = [
    BowelMovementEntry(
      id: 'Dummy002',
      userId: 'jp.sheehan2@gmail.com',
      creationDate: DateTime(2019, 2, 7, 8, 14),
      modificationDate: DateTime(2019, 2, 7, 8, 14),
      dateTime: DateTime(2019, 2, 6, 18, 31),
      bowelMovement: BowelMovement(type: 4, volume: 2),
      notes: '',
    )
  ];

  static List<SymptomEntry> symptomEntries = [
    SymptomEntry(
      id: 'Dummy003',
      userId: 'jp.sheehan2@gmail.com',
      creationDate: DateTime(2019, 2, 7, 8, 14),
      modificationDate: DateTime(2019, 2, 7, 8, 14),
      dateTime: DateTime(2019, 2, 7, 15, 31),
      symptom: Symptom(symptomType: SymptomType(name: 'Bloating'), severity: 6),
      notes: '',
    )
  ];

  static List<DosageEntry> dosesEntries = [
    DosageEntry(
      id: 'Dummy004',
      userId: 'jp.sheehan2@gmail.com',
      creationDate: DateTime(2019, 2, 7, 8, 14),
      modificationDate: DateTime(2019, 2, 7, 8, 14),
      dateTime: DateTime(2019, 2, 7, 12, 0),
      dosage: Dosage(doses: BuiltList<Dose>([
        Dose(
            medicine: Medicine(name: "Pro-8"),
            quantity: Quantity(amount: 1, unit: 'pill')),
        Dose(
            medicine: Medicine(name: "Fiber"),
            quantity: Quantity(amount: 2, unit: 'Tbsp'))
      ])),
      notes: '',
    )
  ];
}
