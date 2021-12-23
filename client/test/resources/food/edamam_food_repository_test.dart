import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/edamam_api/edamam_api_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_service.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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

    test('streames query', () async {
      final streamedFoods = foodRepository.streamQuery('apple');
      await expectLater(streamedFoods, emits(appleQueryEntries.map((e) => e.toEdamamFood())));
    });

    test('streames query with incomplete measures', () async {
      final streamedFoods = foodRepository.streamQuery('avocado');
      await expectLater(streamedFoods, emits(avocadoQueryEntries.map((e) => e.toEdamamFood())));
    });

    test('streames no foods for empty query', () async {
      final streamedFoods = foodRepository.streamQuery('');
      await expectLater(streamedFoods, emits(BuiltList<EdamamFood>([])));
    });

    test('streames no foods for matchless query', () async {
      final streamedFoods = foodRepository.streamQuery('tacos');
      await expectLater(streamedFoods, emits(BuiltList<EdamamFood>([])));
    });

    test('streames single food', () async {
      final streamedFood = foodRepository.streamFood(food.toFoodReference());
      await expectLater(streamedFood, emits(food));
    });

    test('reuses reference data for missing food', () async {
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond');
      final streamedFood = foodRepository.streamFood(missingFoodRef);
      final missingFood = EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name);
      await expectLater(streamedFood, emits(missingFood));
    });

    test('reuses reference data for missing food stream', () async {
      final missingFoodRef = EdamamFoodReference(id: '007', name: 'Bond');
      final streamedFood = foodRepository.streamFood(missingFoodRef);
      final missingFood = EdamamFood(id: missingFoodRef.id, name: missingFoodRef.name);
      await expectLater(streamedFood, emits(missingFood));
    });
  });
}
