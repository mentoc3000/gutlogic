import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('EdamamFood', () {
    test('constructs with empty irritant list', () {
      final food = EdamamFood(id: '123', name: 'Bread');
      expect(food.name, 'Bread');
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
        ],
        'irritants': [
          {'name': 'Fructan', 'concentration': 0.032, 'dosePerServing': 1.23},
        ],
        'ingredients': [
          {'name': 'Brown Rice', 'maxFracWeight': 0.9},
          {'name': 'Water', 'maxFracWeight': 0.09},
          {'name': 'Salt', 'maxFracWeight': 0.01},
        ]
      };
      final food = serializers.deserializeWith(EdamamFood.serializer, foodJson)!;
      expect(food.name, foodJson['name']);
    });

    test('is deserializable with nested ingredients', () {
      final foodJson = {
        'id': 'food_borhzfibq5hk42auqefxmap5wmm1',
        'name': 'Peanut Butter Wafers, Peanut Butter',
        'brand': 'Kid Tested Tunes',
        'measures': [
          {'unit': 'Serving', 'weight': 27},
          {'unit': 'Wafer', 'weight': 9},
          {'unit': 'Gram', 'weight': 1},
          {'unit': 'Ounce', 'weight': 28.349523125},
          {'unit': 'Pound', 'weight': 453.59237},
          {'unit': 'Kilogram', 'weight': 1000}
        ],
        'irritants': null,
        'ingredients': [
          {
            'name': 'VEGETABLE OIL',
            'maxFracWeight': 1,
            'foodReference': null,
            'ingredients': [
              {'name': 'CANOLA', 'maxFracWeight': 1, 'foodReference': null, 'ingredients': null},
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
          },
          {'name': 'SORBITOL', 'maxFracWeight': 0.5, 'foodReference': null, 'ingredients': null},
          {
            'name': 'ENRICHED WHEAT FLOUR',
            'maxFracWeight': 0.3333333333333333,
            'foodReference': null,
            'ingredients': [
              {
                'name': 'WHEAT FLOUR',
                'maxFracWeight': 1,
                'foodReference': {
                  '\$': 'EdamamFoodReference',
                  'name': 'WHEAT FLOUR',
                  'id': 'food_ar3x97tbq9o9p6b6gzwj0am0c81l'
                },
                'ingredients': null
              },
              {'name': 'MALTED BARLEY FLOUR', 'maxFracWeight': 0.5, 'foodReference': null, 'ingredients': null},
              {'name': 'NIACIN', 'maxFracWeight': 0.3333333333333333, 'foodReference': null, 'ingredients': null},
              {'name': 'REDUCED IRON', 'maxFracWeight': 0.25, 'foodReference': null, 'ingredients': null},
              {'name': 'THIAMINE MONONITRATE', 'maxFracWeight': 0.2, 'foodReference': null, 'ingredients': null},
              {'name': 'RIBOFLAVIN', 'maxFracWeight': 0.16666666666666666, 'foodReference': null, 'ingredients': null},
              {'name': 'FOLIC ACID', 'maxFracWeight': 0.14285714285714285, 'foodReference': null, 'ingredients': null}
            ]
          },
          {'name': 'MALTODEXTRIN', 'maxFracWeight': 0.25, 'foodReference': null, 'ingredients': null},
          {
            'name': 'NATURAL PEANUT BUTTER (ROASTED PEANUTS)',
            'maxFracWeight': 0.2,
            'foodReference': null,
            'ingredients': null
          },
          {
            'name': 'CORN STARCH',
            'maxFracWeight': 0.16666666666666666,
            'foodReference': {
              '\$': 'EdamamFoodReference',
              'name': 'CORN STARCH',
              'id': 'food_a6r17hrba37cqeabesko5a2gk233'
            },
            'ingredients': null
          },
          {'name': 'SALT', 'maxFracWeight': 0.14285714285714285, 'foodReference': null, 'ingredients': null},
          {'name': 'SOY LECITHIN', 'maxFracWeight': 0.125, 'foodReference': null, 'ingredients': null},
          {'name': 'BAKING SODA', 'maxFracWeight': 0.1111111111111111, 'foodReference': null, 'ingredients': null},
          {
            'name': 'ASPARTAME (PHENYLKETONURICS: CONTAINS PHENYLALANINE)',
            'maxFracWeight': 0.1,
            'foodReference': null,
            'ingredients': null
          },
          {
            'name': 'AMMONIUM BICARBONATE',
            'maxFracWeight': 0.09090909090909091,
            'foodReference': null,
            'ingredients': null
          },
        ],
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
        'measures': <dynamic>[],
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
