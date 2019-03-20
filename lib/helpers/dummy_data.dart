import 'package:gut_ai/model/food.dart';
import 'package:gut_ai/model/diary_entry.dart';
import 'package:gut_ai/model/bowel_movement.dart';
import 'package:gut_ai/model/medicine.dart';

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

  static List<FoodAndDrinkEntry> foodAndDrinkEntries = [
    FoodAndDrinkEntry(
      dateTime: DateTime(2019, 2, 7, 8, 14), 
      food: Food(name: "Bread", irritants: ['Fructans']),
      quantity: "1 slice"
    ),
    FoodAndDrinkEntry(
      dateTime: DateTime(2019, 2, 7, 8, 14), 
      food: Food(name: "Egg", irritants: []),
      quantity: "1 each"
    )
  ];

  static List<BowelMovementEntry> bowelMovementEntries = [
    BowelMovementEntry(
      dateTime: DateTime(2019, 2, 7, 11, 31),
      bowelMovement: BowelMovement(type: 4, volume: 2),
    )
  ];

  static List<MedicineEntry> medicineEntries = [
    MedicineEntry(
      dateTime: DateTime(2019, 2, 7, 12, 0),
      medicine: Medicine(name: "Pro-8"),
      dose: "1 pill"
    ),
    MedicineEntry(
      dateTime: DateTime(2019, 2, 7, 12, 0),
      medicine: Medicine(name: "Fiber"),
      dose: "1 Tbsp"
    ),
  ];
}