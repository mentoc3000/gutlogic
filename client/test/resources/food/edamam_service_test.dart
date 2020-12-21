import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/firebase/cloud_function_service.dart';
import 'edamam_sample_data.dart';

void main() {
  EdamamService edamamService;
  group('EdamamService', () {
    CloudFunctionService edamamFoodSearchService;
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

    setUp(() {
      edamamFoodSearchService = MockCloudFunctionService();
      when(edamamFoodSearchService.callWith({'query': riceCakeId})).thenAnswer((_) async => riceCakeResponse);
      when(edamamFoodSearchService.callWith({'query': query})).thenAnswer((_) async => appleResponse);
      edamamService = EdamamService(edamamFoodSearchService: edamamFoodSearchService);
    });

    test('gets food by id', () async {
      final food = await edamamService.getById(riceCakeId);
      expect(food['food']['label'], 'brown rice cake');
    });

    test('searches foods', () async {
      final results = await edamamService.searchFood(query);
      expect(results.length, 22);
      expect(results[0]['food']['foodId'], 'food_a1gb9ubb72c7snbuxr3weagwv0dd');
    });
  });
}

class MockCloudFunctionService extends Mock implements CloudFunctionService {}
