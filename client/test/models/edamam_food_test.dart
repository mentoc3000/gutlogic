import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/irritant.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('EdamamFood', () {
    test('constructs with empty irritant list', () {
      final food = EdamamFood(id: '123', name: 'Bread');
      expect(food.name, 'Bread');
      expect(food.irritants, null);
    });

    test('constructs with irritant list', () {
      final irritants = [Irritant(name: 'Fructan', concentration: .0032), Irritant(name: 'Sorbitol')].build();
      final food = EdamamFood(id: '123', name: 'Bread', irritants: irritants);
      expect(food.name, 'Bread');
      expect(food.irritants!.length, irritants.length);
    });

    test('is equatable', () {
      EdamamFood constructFood() => EdamamFood(id: '123', name: 'Bread');
      expect(constructFood(), constructFood());
    });

    test('is deserializable', () {
      final foodJson = {
        'id': 'food_a7t4ob2aynrl25ayhq4n8adgykn5',
        'name': 'brown rice cake',
        'nutrients': {'ENERC_KCAL': 387, 'PROCNT': 8.2, 'FAT': 2.8, 'CHOCDF': 81.5, 'FIBTG': 4.2},
        'category': 'Generic foods',
        'categoryLabel': 'food',
        'image': 'https://www.edamam.com/food-img/0c6/0c6ecebeb0f344ed6a82d67cc446cdda.jpg',
        'measures': [
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_unit', 'label': 'Whole', 'weight': 9},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_serving', 'label': 'Serving', 'weight': 18},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_cake', 'label': 'Cake', 'weight': 9},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_gram', 'label': 'Gram', 'weight': 1},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_ounce', 'label': 'Ounce', 'weight': 28.349524},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_pound', 'label': 'Pound', 'weight': 453.59238},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_kilogram', 'label': 'Kilogram', 'weight': 1000}
        ]
      };
      final food = serializers.deserializeWith(EdamamFood.serializer, foodJson)!;
      expect(food.name, foodJson['name']);
    });

    test('is serializable', () {
      final food = EdamamFood.fromBuilder((b) => b
        ..id = '1234'
        ..name = 'Bread');
      expect(serializers.serialize(food), {
        '\$': 'EdamamFood',
        'measures': [],
        'id': '1234',
        'name': food.name,
      });
    });

    test('has a search heading', () {
      final food = EdamamFood(id: '123', name: 'Bread');
      expect(food.searchHeading(), food.name);
    });

    test('converts to FoodReference', () {
      final food = EdamamFood(id: '123', name: 'Bread');
      final foodReference = food.toFoodReference();
      expect(foodReference.id, food.id);
      expect(foodReference.name, food.name);
    });
  });
}
