import 'ingredient.dart';

class Meal {
  String name;
  List<Ingredient> ingredients;

  Meal({this.name, List<Ingredient> ingredients}) {
    this.ingredients = ingredients ?? [];
  }
}
