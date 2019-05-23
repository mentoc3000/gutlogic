import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/meal.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'package:gut_ai/models/food.dart';

void main() {
  group('Meal', () {
    test('constructs empty object', () {
      Meal meal = Meal();
      expect(meal.name, null);
      expect(meal.ingredients, []);
    });

    test('constructs simple object', () {
      String name = 'meal name';
      List<Ingredient> ingredients = [Ingredient()];
      Meal meal = Meal(
        name: name,
        ingredients: ingredients,
      );
      expect(meal.name, name);
      expect(meal.ingredients, ingredients);
    });

    test('is equatable', () {
      final constructMeal = () => Meal(
            name: 'meal name',
            ingredients: [Ingredient()],
          );
      expect(constructMeal(), constructMeal());
    });

    test('is deserializable', () {
      String name = 'Breakfast';
      List<Ingredient> ingredients = [Ingredient(food: Food(name: 'Banana'))];
      Map<String, dynamic> mealJson = {
        'name': name,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };
      Meal meal = Meal.fromJson(mealJson);
      expect(meal.name, name);
      expect(meal.ingredients, ingredients);
    });

    test('is serializable', () {
      Ingredient ingredient = Ingredient(food: Food(name: 'Pizza'));
      Meal meal = Meal(
        name: 'Breakfast',
        ingredients: [ingredient],
      );
      expect(meal.toJson(), {
        'name': 'Breakfast',
        'ingredients': [ingredient.toJson()],
      });
    });
  });
}
