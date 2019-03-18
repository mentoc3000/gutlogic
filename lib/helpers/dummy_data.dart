import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/model/FoodList.dart';
import 'package:gi_bliss/model/diary_entry.dart';

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

  static final _foods = [_artichoke, _creamCheese, _egg];

  static final foodList = FoodList(foods: _foods);



  List<FoodAndDrinkEntry> foodAndDrinkEntries = [
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

  List<BowelMovementEntry> bowelMovementEntries = [
    BowelMovementEntry(
      dateTime: DateTime(2019, 2, 7, 11, 31),
      consistency: 4,
      volume: 2
    )
  ];

  List<MedicineEntry> medicineEntries = [
    MedicineEntry(
      dateTime: DateTime(2019, 2, 7, 12, 0),
      medicine: "Pro-8",
      dose: "1 pill"
    )
  ];
}