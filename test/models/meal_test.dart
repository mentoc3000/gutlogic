import 'package:test/test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gut_ai/models/meal.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Meal', () {
    test('constructs simple object', () {
      BuiltList<Ingredient> ingredients = BuiltList<Ingredient>([
        Ingredient((b) => b
          ..food.name = 'Fructan'
          ..quantity.amount = 1.2
          ..quantity.unit = 'slices'),
      ]);
      Meal meal = Meal((b) => b..ingredients = ingredients.toBuilder());
      expect(meal.ingredients, ingredients);
    });

    test('constructs with empty ingredient list', () {
      BuiltList<Ingredient> ingredients = BuiltList<Ingredient>([]);
      Meal meal = Meal((b) => b..ingredients = ingredients.toBuilder());
      expect(meal.ingredients, ingredients);
    });

    test('is equatable', () {
      final constructFood = () {
        BuiltList<Ingredient> ingredients = BuiltList<Ingredient>([
          Ingredient((b) => b
            ..food.name = 'Fructan'
            ..quantity.amount = 1.2
            ..quantity.unit = 'slices'),
        ]);
        Meal meal = Meal((b) => b..ingredients = ingredients.toBuilder());
        return meal;
      };
      expect(constructFood(), constructFood());
    });

    test('is deserializable', () {
      Map<String, dynamic> mealJson = {
        'ingredients': [
          {
            'food': {'name': 'Bread'},
            'quantity': {'amount': 1.2, 'unit': 'Slices'},
          },
        ],
      };
      Meal meal = serializers.deserializeWith(Meal.serializer, mealJson);
      expect(meal.ingredients[0].food.name, 'Bread');
    });

    test('is serializable', () {
      BuiltList<Ingredient> ingredients = BuiltList<Ingredient>([
        Ingredient((b) => b
          ..food.name = 'Fructan'
          ..quantity.amount = 1.2
          ..quantity.unit = 'slices'),
      ]);
      Meal meal = Meal((b) => b..ingredients = ingredients.toBuilder());
      expect(serializers.serialize(meal), {
        '\$': 'Meal',
        'ingredients': ingredients.map((i) {
          Map<String, dynamic> irritantJson = serializers.serialize(i);
          return irritantJson..remove('\$');
        }).toList(),
      });
    });
  });
}
