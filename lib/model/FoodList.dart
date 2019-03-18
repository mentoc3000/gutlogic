import 'food.dart';

class FoodList {
  List<Food> foods = new List();

  FoodList({
    this.foods
  });

  factory FoodList.fromJson(List<dynamic> parsedJson) {
    List<Food> foods = new List<Food>();

    foods = parsedJson.map((i) => Food.fromJson(i)).toList();

    return new FoodList(foods: foods);
  }
}