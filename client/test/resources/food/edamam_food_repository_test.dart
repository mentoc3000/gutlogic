import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/models/edamam_api/edamam_api_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'edamam_food_repository_test.mocks.dart';
import 'edamam_sample_data.dart';

@GenerateMocks([EdamamService, PantryRepository])
void main() {
  group('EdamamFoodRepository', () {
    late EdamamFoodRepository foodRepository;
    late MockEdamamService edamamService;
    late EdamamFood food;

    setUp(() async {
      food = brownRiceCakeEntry.toEdamamFood()!;

      edamamService = MockEdamamService();
      when(edamamService.getById(any)).thenAnswer((_) => Future.value(brownRiceCakeEntry));
      when(edamamService.searchFood(any)).thenAnswer((_) => Future.value(<EdamamApiEntry>[]));
      when(edamamService.searchFood('apple')).thenAnswer((_) => Future.value(appleQueryEntries));
      when(edamamService.searchFood('avocado')).thenAnswer((_) => Future.value(avocadoQueryEntries));

      foodRepository = EdamamFoodRepository(edamamService: edamamService);
    });

    test('fetches query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('apple');
      expect(fetchedFoods.length, appleQueryEntries.length);
    });

    test('fetches query with incomplete measures', () async {
      final fetchedFoods = await foodRepository.fetchQuery('avocado');
      expect(fetchedFoods.length, avocadoQueryEntries.length);
    });

    test('fetches no foods for empty query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('');
      expect(fetchedFoods.length, 0);
    });

    test('fetches no foods for matchless query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('tacos');
      expect(fetchedFoods.length, 0);
    });

    test('fetches single food', () async {
      final fetchedFood = await foodRepository.fetchFood(food.toFoodReference());
      expect(fetchedFood, food);
    });

    test('streams query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('apple');
      await expectLater(foodRepository.streamQuery('apple'), emits(fetchedFoods));
    });
  });
}
