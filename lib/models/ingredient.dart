import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'food.dart';
import 'quantity.dart';
import 'model_interfaces.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient extends Equatable implements Searchable{
  Food food;
  Quantity quantity;

  Ingredient({this.food, this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  String searchHeading() => food.name;
}
