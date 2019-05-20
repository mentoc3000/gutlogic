import 'package:equatable/equatable.dart';
import 'food.dart';
import 'quantity.dart';
import 'model_interfaces.dart';

class Ingredient extends Equatable implements Searchable{
  Food food;
  Quantity quantity;

  Ingredient({this.food, this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> parsedJson) {
    return Ingredient(
      food: Food.fromJson(parsedJson['food']),
      quantity: Quantity.fromJson(parsedJson['volume']),
    );
  }

  String searchHeading() => food.name;
}
