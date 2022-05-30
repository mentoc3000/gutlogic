import 'package:gutlogic/models/edamam_api/edamam_api_entry.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

import '../resources/food/edamam_sample_data.dart';

void main() {
  group('EdamamEntry', () {
    test('is serializable', () {
      final asparagus = serializers.deserializeWith(EdamamApiEntry.serializer, asparagusResult);
      expect(asparagus!.measures[2].qualified![1].weight, 16.0);
    });

    test('converts to EdamamFood', () {
      final asparagusNative = serializers.deserializeWith(EdamamApiEntry.serializer, asparagusResult);
      final asparagus = asparagusNative!.toEdamamFood();
      expect(asparagus!.measures[4].unit, 'Spear, extra large');
    });

    test('converts with empty measure data', () {
      const incompleteResult = {
        'food': {
          'foodId': 'food_b7bgzddbqq26mia27xpv7acn083m',
          'uri': 'http://www.edamam.com/ontologies/edamam.owl#Food_asparagus',
          'label': 'Asparagus',
          'nutrients': {'ENERC_KCAL': 20.0, 'PROCNT': 2.2, 'FAT': 0.12, 'CHOCDF': 3.88, 'FIBTG': 2.1},
          'category': 'Generic foods',
          'categoryLabel': 'food',
          'image': 'https://www.edamam.com/food-img/159/159dec8bbcabf7ed641a57b40a2d2eb9.jpg'
        },
        'measures': [
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_unit', 'label': 'Whole', 'weight': 16.0},
          {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_bunch', 'weight': 226.5},
          {
            'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_spear',
            'label': 'Spear',
            'weight': 16.0,
            'qualified': [
              {
                'qualifiers': [
                  {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_small', 'label': 'small'}
                ],
                'weight': 12.0
              },
              {'qualifiers': <dynamic>[], 'weight': 16.0},
              {
                'qualifiers': [
                  {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_extra_large', 'label': 'extra large'}
                ],
              }
            ]
          },
        ]
      };

      final nativeFood = serializers.deserializeWith(EdamamApiEntry.serializer, incompleteResult);
      final food = nativeFood!.toEdamamFood();
      expect(food!.measures.length, 2);
    });
  });
}
