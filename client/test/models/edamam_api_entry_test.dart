import 'package:test/test.dart';
import 'package:gutlogic/models/edamam_api/edamam_api_entry.dart';
import 'package:gutlogic/models/serializers.dart';

void main() {
  group('EdamamApiEntry', () {
    test('is deserializable', () {
      final edamamApiEntry = serializers.deserializeWith(EdamamApiEntry.serializer, asparagusResponse)!;
      expect(edamamApiEntry.food.label, 'Asparagus');
      expect(edamamApiEntry.irritants!.firstWhere((i) => i.name == 'Kestose').concentration, 0.0009);
    });

    test('converts to food', () {
      final edamamApiEntry = serializers.deserializeWith(EdamamApiEntry.serializer, asparagusResponse)!;
      final edamamFood = edamamApiEntry.toEdamamFood()!;
      expect(edamamFood.irritants!.length, 6);
      expect(edamamFood.irritants!.firstWhere((i) => i.name == 'Mannitol').concentration, 0.0009);
      expect(edamamFood.irritants!.firstWhere((i) => i.name == 'Oligosaccharides').concentration, null);
      expect(edamamFood.irritants!.map((e) => e.name).contains('Raffinose'), false);
      expect(edamamFood.irritants!.map((e) => e.name).contains('Sorbitol'), false);
    });
  });
}

const Map<String, dynamic> asparagusResponse = {
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
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_bunch', 'label': 'Bunch', 'weight': 226.5},
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
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_medium', 'label': 'medium'}
          ],
          'weight': 16.0
        },
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_extra_large', 'label': 'extra large'}
          ],
          'weight': 24.0
        },
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_large', 'label': 'large'}
          ],
          'weight': 20.0
        }
      ]
    },
    {
      'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_stalk',
      'label': 'Stalk',
      'weight': 16.0,
      'qualified': [
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_small', 'label': 'small'}
          ],
          'weight': 12.0
        },
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_extra_large', 'label': 'extra large'}
          ],
          'weight': 24.0
        },
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_medium', 'label': 'medium'}
          ],
          'weight': 16.0
        },
        {
          'qualifiers': [
            {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Qualifier_large', 'label': 'large'}
          ],
          'weight': 20.0
        }
      ]
    },
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_ear', 'label': 'Ear', 'weight': 16.0},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_stem', 'label': 'Stem', 'weight': 16.0},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_stalk_tip', 'label': 'Stalk tip', 'weight': 3.5},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_gram', 'label': 'Gram', 'weight': 1.0},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_ounce', 'label': 'Ounce', 'weight': 28.349523125},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_pound', 'label': 'Pound', 'weight': 453.59237},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_kilogram', 'label': 'Kilogram', 'weight': 1000.0},
    {'uri': 'http://www.edamam.com/ontologies/edamam.owl#Measure_cup', 'label': 'Cup', 'weight': 134.0}
  ],
  'irritants': [
    {'name': 'Fructose', 'isPresent': true, 'concentration': 0.0316},
    {'name': 'Glucose', 'isPresent': true, 'concentration': 0.0275},
    {'name': 'Kestose', 'isPresent': true, 'concentration': 0.0009},
    {'name': 'Mannitol', 'isPresent': true, 'concentration': 0.0009},
    {'name': 'Nystose', 'isPresent': true, 'concentration': 0.0034000000000000002},
    {'name': 'Oligosaccharides', 'isPresent': true, 'concentration': null},
    {'name': 'Raffinose', 'isPresent': false, 'concentration': null},
    {'name': 'Sorbitol', 'isPresent': false, 'concentration': 0.0},
    {'name': 'Stachyose', 'isPresent': false, 'concentration': 0}
  ],
};
