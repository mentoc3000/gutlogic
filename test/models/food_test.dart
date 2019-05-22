import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/models/irritant.dart';

void main() {
  group('Food', () {
    test('constructs empty object', () {
      Food food = Food();
      expect(food.name, null);
      expect(food.irritants, []);
    });

    test('constructs simple object', () {
      const name = 'Bread';
      final List<Irritant> irritants = [
        Irritant(name: 'Fructan'),
        Irritant(name: 'Manitol')
      ];
      Food food = Food(name: name, irritants: irritants);
      expect(food.name, name);
      expect(food.irritants, irritants);
    });

    test('is equatable', () {
      final constructFood = () => Food(
            name: 'Orange Juice',
            irritants: [Irritant(name: 'Fructose')],
          );
      expect(constructFood(), constructFood());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> foodJson = {
        'name': 'Pizza',
        'irritants': [
          {'name': 'Garlic'},
        ],
      };
      Food food = Food.fromJson(foodJson);
      expect(food.name, foodJson['name']);
      expect(food.irritants, [Irritant(name: 'Garlic')]);
    });
  });
}
