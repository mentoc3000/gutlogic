import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:mockito/mockito.dart';
import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'edamam_sample_data.dart';

void main() {
  group('EdamamFoodRepository', () {
    String foodId;
    EdamamFoodRepository foodRepository;
    EdamamService edamamService;
    EdamamFood food;
    const foodResult = brownRiceCakeResult;
    const appleQueryResult = appleQueryResults;
    const avocadoQueryResult = avocadoQueryResults;

    setUp(() async {
      final Map<String, Object> foodInfo = foodResult['food'];
      foodId = foodInfo['foodId'];
      food = EdamamFood(
        id: foodId,
        name: foodInfo['label'],
        measures: [
          Measure(unit: 'Whole', weight: 9),
          Measure(unit: 'Serving', weight: 18),
          Measure(unit: 'Cake', weight: 9),
          Measure(unit: 'Gram', weight: 1),
          Measure(unit: 'Ounce', weight: 28.349524),
          Measure(unit: 'Pound', weight: 453.59238),
          Measure(unit: 'Kilogram', weight: 1000),
        ].build(),
      );
      edamamService = MockEdamamService();
      when(edamamService.getById(foodId)).thenAnswer((_) => Future.value(foodResult));
      when(edamamService.searchFood('apple')).thenAnswer((_) => Future.value(appleQueryResult));
      when(edamamService.searchFood('avocado')).thenAnswer((_) => Future.value(avocadoQueryResult));
      foodRepository = EdamamFoodRepository(edamamService: edamamService);
    });

    test('fetches query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('apple');
      expect(fetchedFoods.length, appleQueryResult.length);
    });

    test('fetches query with incomplete measures', () async {
      final fetchedFoods = await foodRepository.fetchQuery('avocado');
      expect(fetchedFoods.length, avocadoQueryResult.length);
    });

    test('fetches no food for empty query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('');
      expect(fetchedFoods.length, 0);
    });

    test('fetches single food', () async {
      final fetchedFood = await foodRepository.fetchItem(foodId);
      expect(fetchedFood, food);
    });

    test('streams query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('apple');
      await expectLater(foodRepository.streamQuery('apple'), emits(fetchedFoods));
    });
  });
}

class MockEdamamService extends Mock implements EdamamService {}
