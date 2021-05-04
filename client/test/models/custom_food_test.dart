import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('CustomFood', () {
    test('constructs with empty irritant list', () {
      final food = CustomFood(id: '123', name: 'Bread');
      expect(food.name, 'Bread');
    });

    test('is equatable', () {
      CustomFood constructFood() => CustomFood(id: '123', name: 'Bread');
      expect(constructFood(), constructFood());
    });

    test('is deserializable', () {
      final foodJson = {
        'id': '1234',
        'name': 'Pizza',
      };
      final food = serializers.deserializeWith(CustomFood.serializer, foodJson)!;
      expect(food.name, foodJson['name']);
    });

    test('is serializable', () {
      final food = CustomFood.fromBuilder((b) => b
        ..id = '1234'
        ..name = 'Bread');
      expect(serializers.serialize(food), {
        '\$': 'CustomFood',
        'measures': [],
        'id': '1234',
        'name': food.name,
      });
    });

    test('has a search heading', () {
      final food = CustomFood(id: '123', name: 'Bread');
      expect(food.searchHeading(), food.name);
    });

    test('converts to FoodReference', () {
      final food = CustomFood(id: '123', name: 'Bread');
      final foodReference = food.toFoodReference();
      expect(foodReference.id, food.id);
      expect(foodReference.name, food.name);
    });
  });
}
