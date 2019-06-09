import 'package:test/test.dart';
import 'package:gut_ai/models/serializers.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('Ingredient', () {
    test('constructs simple object', () {
      Food food = Food((b) => b..name = 'Tomato');
      Quantity quantity = Quantity((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Ingredient ingredient = Ingredient((b) => b
        ..food = food.toBuilder()
        ..quantity = quantity.toBuilder());
      expect(ingredient.food, food);
      expect(ingredient.quantity, quantity);
    });

    test('is equatable', () {
      final constructIngredient = () {
        Food food = Food((b) => b..name = 'Tomato');
        Quantity quantity = Quantity((b) => b
          ..amount = 3.4
          ..unit = 'Slices');
        Ingredient ingredient = Ingredient((b) => b
          ..food = food.toBuilder()
          ..quantity = quantity.toBuilder());
        return ingredient;
      };
      expect(constructIngredient(), constructIngredient());
    });

    test('is deserializable', () {
      Food food = Food((b) => b..name = 'Tomato');
      Quantity quantity = Quantity((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Map<String, dynamic> foodJson = serializers.serialize(food);
      Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      Map<String, dynamic> ingredientJson = {
        'food': foodJson..remove('\$'),
        'quantity': quantityJson..remove('\$'),
      };
      Ingredient ingredient = serializers.deserializeWith(Ingredient.serializer, ingredientJson);
      expect(ingredient.food, food);
      expect(ingredient.quantity, quantity);
    });

    test('is serializable', () {
      Food food = Food((b) => b..name = 'Tomato');
      Quantity quantity = Quantity((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Ingredient ingredient = Ingredient((b) => b
        ..food = food.toBuilder()
        ..quantity = quantity.toBuilder());
      Map<String, dynamic> foodJson = serializers.serialize(food);
      Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      expect(serializers.serialize(ingredient), {
        '\$': 'Ingredient',
        'food': foodJson..remove('\$'),
        'quantity': quantityJson..remove('\$'),
      });
    });
  });
}
