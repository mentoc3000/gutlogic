import 'package:gutlogic/resources/api_service.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'edamam_sample_data.dart';
import 'edamam_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('EdamamService', () {
    late EdamamService edamamService;
    const riceCakeId = 'food_a7t4ob2aynrl25ayhq4n8adgykn5';
    const riceCakeResponse = {'data': brownRiceCakeResult};

    const query = 'apple';
    const appleResponse = {'data': appleQueryResults};

    const missingId = 'nothinghere';

    late MockApiService apiService;

    setUp(() {
      apiService = MockApiService();
      edamamService = EdamamService(apiService: apiService);
    });

    test('gets food by id', () async {
      when(apiService.get(path: '/food/v0/$riceCakeId', params: argThat(isNull, named: 'params')))
          .thenAnswer((_) => Future.value(riceCakeResponse));
      final edamamFood = await edamamService.getById(riceCakeId);
      expect(edamamFood!.name, 'brown rice cake');
    });

    test('returns null for missing food', () async {
      when(apiService.get(path: argThat(startsWith('/food'), named: 'path'), params: anyNamed('params')))
          .thenAnswer((_) => Future.value({'data': null}));
      final edamamFood = await edamamService.getById(missingId);
      expect(edamamFood, null);
    });

    test('searches foods', () async {
      when(apiService.get(path: '/food/v0/search', params: anyNamed('params')))
          .thenAnswer((_) => Future.value(appleResponse));
      final results = await edamamService.searchFood(query);
      expect(results.length, 22);
      expect(results[0].id, 'food_a1gb9ubb72c7snbuxr3weagwv0dd');
    });

    test('returns nothing for missing food', () async {
      when(apiService.get(path: argThat(startsWith('/food/v0/search'), named: 'path'), params: anyNamed('params')))
          .thenAnswer((_) => Future.value({'data': <Map<String, dynamic>>[]}));
      final results = await edamamService.searchFood(missingId);
      expect(results.length, 0);
    });
  });
}
