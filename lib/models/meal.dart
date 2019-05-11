import 'ingredient.dart';

class Meal {
  String name;
  List<Ingredient> ingredients;

  Meal({this.name, List<Ingredient> ingredients}) {
    this.ingredients = ingredients ?? [];
  }

  factory Meal.fromJson(Map<String, dynamic> parsedJson) {
    List<Map<String, dynamic>> ingredients = parsedJson['ingredients'];
    return Meal(
      name: parsedJson['name'],
      ingredients: ingredients.map((x) => Ingredient.fromJson(x)),
    );
  }
}
