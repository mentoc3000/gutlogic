import 'package:gi_bliss/model/Food.dart';
import 'package:gi_bliss/model/FoodList.dart';

class DummyFoods {
  static final _artichoke = Food(name: 'Artichoke', irritants: ['Fructans', 'Fructose']);
  static final _creamCheese = Food(name: 'Cream Cheese', irritants: ['Lactose']);
  static final _egg = Food(name: 'Egg', irritants: []);
  static final foods = [_artichoke, _creamCheese, _egg];
  static final dummyFoods = FoodList(foods: foods);
}