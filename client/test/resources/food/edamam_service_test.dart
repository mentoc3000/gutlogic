import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/firebase/cloud_function_service.dart';

import 'edamam_sample_data.dart';
import 'edamam_service_test.mocks.dart';

@GenerateMocks([CloudFunctionService])
void main() {
  late EdamamService edamamService;
  group('EdamamService', () {
    late MockCloudFunctionService edamamFoodSearchService;
    const riceCakeId = 'food_a7t4ob2aynrl25ayhq4n8adgykn5';
    const riceCakeResponse = {
      'status': 200,
      'data': {
        'hints': [brownRiceCakeResult]
      }
    };

    const query = 'apple';
    const appleResponse = {
      'status': 200,
      'data': {'hints': appleQueryResults}
    };

    const missingId = 'nothinghere';
    const missingResponse = {
      'status': 404,
      'data': {'error': 'not_found'}
    };

    setUp(() {
      edamamFoodSearchService = MockCloudFunctionService();
      when(edamamFoodSearchService.callWith({'query': riceCakeId})).thenAnswer((_) async => riceCakeResponse);
      when(edamamFoodSearchService.callWith({'query': query})).thenAnswer((_) async => appleResponse);
      when(edamamFoodSearchService.callWith({'query': missingId})).thenAnswer((_) async => missingResponse);
      edamamService = EdamamService(edamamFoodSearchService: edamamFoodSearchService);
    });

    test('gets food by id', () async {
      final edamamEntry = await edamamService.getById(riceCakeId);
      expect(edamamEntry!.food.label, 'brown rice cake');
    });

    test('returns null for missing food', () async {
      final edamamEntry = await edamamService.getById(missingId);
      expect(edamamEntry, null);
    });

    test('searches foods', () async {
      final results = await edamamService.searchFood(query);
      expect(results.length, 22);
      expect(results[0].food.foodId, 'food_a1gb9ubb72c7snbuxr3weagwv0dd');
    });

    test('returns nothing for missing food', () async {
      final results = await edamamService.searchFood(missingId);
      expect(results.length, 0);
    });
  });
}
