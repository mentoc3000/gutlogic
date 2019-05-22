import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'ingredient.dart';

part 'meal.g.dart';

@JsonSerializable()
class Meal extends Equatable {
  String name;
  List<Ingredient> ingredients;

  Meal({this.name, List<Ingredient> ingredients}) {
    this.ingredients = ingredients ?? [];
  }

  factory Meal.fromJson(Map<String, dynamic> json) =>
      _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);
}
