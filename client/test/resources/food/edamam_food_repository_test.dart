import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/models/edamam_api/edamam_api_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'edamam_food_repository_test.mocks.dart';
import 'edamam_sample_data.dart';

@GenerateMocks([EdamamService, PantryService])
void main() {
  group('EdamamFoodRepository', () {
    late EdamamFoodRepository foodRepository;
    late MockEdamamService edamamService;
    late EdamamFood food;

    setUp(() async {
      food = brownRiceCakeEntry.toEdamamFood()!;

      edamamService = MockEdamamService();
      when(edamamService.getById(any)).thenAnswer((_) => Future.value(null));
      when(edamamService.getById(brownRiceCakeEntry.food.foodId)).thenAnswer((_) => Future.value(brownRiceCakeEntry));
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

    test('reuses reference data for missing food', () async {
      final irritant = Irritant(name: 'fructan');
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond', irritants: [irritant].build());
      final fetchedFood = await foodRepository.fetchFood(missingFoodRef);
      final missingFood =
          EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name, irritants: missingFoodRef.irritants);
      expect(fetchedFood, missingFood);
    });

    test('streams query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('apple');
      await expectLater(foodRepository.streamQuery('apple'), emits(fetchedFoods));
    });

    test('reuses reference data for missing food stream', () async {
      final irritant = Irritant(name: 'fructan');
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond', irritants: [irritant].build());
      final fetchedFood = foodRepository.streamFood(missingFoodRef);
      final missingFood =
          EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name, irritants: missingFoodRef.irritants);
      await expectLater(fetchedFood, emits(missingFood));
    });
  });
}
