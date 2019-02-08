import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/model/FoodList.dart';

class DummyFoods {
  static final _artichoke = Food(
    name: 'Artichoke', 
    irritants: {
      'Fructans': 1, 
      'Fructose': 2
    }
  );
  static final _creamCheese = Food(
    name: 'Cream Cheese', 
    irritants: {
      'Lactose': 2
    }
  );
  static final _egg = Food(
    name: 'Egg', 
    irritants: {}
  );

  static final _foods = [_artichoke, _creamCheese, _egg];

  static final dummyFoods = FoodList(foods: _foods);
}