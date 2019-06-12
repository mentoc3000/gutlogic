import 'package:test/test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gut_ai/models/food.dart';
import 'package:gut_ai/models/irritant.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Food', () {
    test('constructs simple object', () {
      BuiltList<Irritant> irritants = BuiltList<Irritant>([
        Irritant((b) => b..name = 'Fructan'),
        Irritant((b) => b..name = 'Fructose'),
      ]);
      Food food = Food(name: 'Bread', irritants: irritants);
      expect(food.name, 'Bread');
      expect(food.irritants, irritants);
    });

    test('constructs with empty irritant list', () {
      BuiltList<Irritant> irritants = BuiltList<Irritant>([]);
      Food food = Food.fromBuilder((b) => b
        ..name = 'Bread'
        ..irritants = irritants.toBuilder());
      expect(food.name, 'Bread');
      expect(food.irritants, irritants);
    });

    test('is equatable', () {
      final constructFood = () {
        BuiltList<Irritant> irritants = BuiltList<Irritant>([
          Irritant((b) => b..name = 'Fructan'),
          Irritant((b) => b..name = 'Fructose'),
        ]);
        Food food = Food.fromBuilder((b) => b
          ..name = 'Bread'
          ..irritants = irritants.toBuilder());
        return food;
      };
      expect(constructFood(), constructFood());
    });

    test('is deserializable', () {
      Map<String, dynamic> foodJson = {
        'name': 'Pizza',
        'irritants': [
          {'name': 'Bread'},
        ],
      };
      Food food = serializers.deserializeWith(Food.serializer, foodJson);
      expect(food.name, foodJson['name']);
      expect(food.irritants[0].name, 'Bread');
    });

    test('is serializable', () {
      BuiltList<Irritant> irritants = BuiltList<Irritant>([
        Irritant((b) => b..name = 'Fructan'),
        Irritant((b) => b..name = 'Fructose'),
      ]);
      Food food = Food.fromBuilder((b) => b
        ..name = 'Bread'
        ..irritants = irritants.toBuilder());
      expect(serializers.serialize(food), {
        '\$': 'Food',
        'name': food.name,
        'irritants': irritants.map((i) {
          Map<String, dynamic> irritantJson = serializers.serialize(i);
          return irritantJson..remove('\$');
        }).toList(),
      });
    });

    test('has a search heading', () {
      Food food = Food.fromBuilder((b) => b..name = 'Bread');
      expect(food.searchHeading(), food.name);
    });
  });
}
