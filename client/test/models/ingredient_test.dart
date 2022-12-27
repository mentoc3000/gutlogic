import 'package:gutlogic/models/food/ingredient.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Ingredient', () {
    test('constructs with empty irritant list', () {
      final food = Ingredient(name: 'Bread');
      expect(food.name, 'Bread');
    });

    test('is equatable', () {
      Ingredient constructFood() => Ingredient(name: 'Bread');
      expect(constructFood(), constructFood());
    });

    test('is deserializable', () {
      final foodJson = {
        'name': 'VEGETABLE OIL',
        'maxFracWeight': 1,
        'foodReference': null,
        'ingredients': [
          {
            'name': 'CANOLA',
            'maxFracWeight': 1,
            'foodReference': null,
            'ingredients': null,
          },
          {
            'name': 'SOYBEAN',
            'maxFracWeight': 0.5,
            'foodReference': {
              '\$': 'EdamamFoodReference',
              'name': 'SOYBEAN',
              'id': 'food_bx3fkcubyl2t7ha8jfdm5anoirlx'
            },
            'ingredients': null
          },
          {'name': 'PALM', 'maxFracWeight': 0.3333333333333333, 'foodReference': null, 'ingredients': null},
          {'name': 'PALM KERNEL', 'maxFracWeight': 0.25, 'foodReference': null, 'ingredients': null}
        ]
      };
      final food = serializers.deserializeWith(Ingredient.serializer, foodJson)!;
      expect(food.name, foodJson['name']);
    });
  });
}
