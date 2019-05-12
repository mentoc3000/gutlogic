import 'package:equatable/equatable.dart';
import 'food.dart';
import 'quantity.dart';

class Ingredient extends Equatable {
  Food food;
  Quantity quantity;

  Ingredient({this.food, this.quantity});

  factory Ingredient.copy(Ingredient original) {
    return Ingredient(food: original.food, quantity: original.quantity);
  }

  factory Ingredient.fromJson(Map<String, dynamic> parsedJson) {
    return Ingredient(
      food: Food.fromJson(parsedJson['food']),
      quantity: Quantity.fromJson(parsedJson['volume']),
    );
  }
}
