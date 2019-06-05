import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('Ingredient', () {

    test('constructs simple object', () {
      Food food = Food();
      Quantity quantity = Quantity();
      Ingredient ingredient = Ingredient(
        food: food,
        quantity: quantity,
      );
      expect(ingredient.food, food);
      expect(ingredient.quantity, quantity);
    });

    test('is equatable', () {
      final constructIngredient = () => Ingredient(
            food: Food(),
            quantity: Quantity(),
          );
      expect(constructIngredient(), constructIngredient());
    });

    test('is deserializable', () {
      Food food = Food(name: 'Pro-8');
      Quantity quantity = Quantity(amount: 3, unit: 'Pills');
      Map<String, dynamic> ingredientJson = {
        'food': food.toJson(),
        'quantity': quantity.toJson(),
      };
      Ingredient ingredient = Ingredient.fromJson(ingredientJson);
      expect(ingredient.food, food);
      expect(ingredient.quantity, quantity);
    });

    test('is serializable', () {
      Quantity quantity = Quantity(amount: 1.2);
      Food food = Food(
        name: 'Garlic',
      );
      Ingredient ingredient = Ingredient(
            food: food,
            quantity: quantity,
          );
      expect(ingredient.toJson(), {
        'food': food.toJson(),
        'quantity': quantity.toJson(),
      });
    });
  });
}
