import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'food_service_test.mocks.dart';

@GenerateMocks([CustomFoodRepository, EdamamFoodRepository, PantryRepository])
void main() {
  group('FoodRepository', () {
    late MockPantryRepository pantryRepository;
    late MockCustomFoodRepository customFoodRepository;
    late MockEdamamFoodRepository edamamFoodRepository;
    late CustomFood customFood;
    late EdamamFood edamamFood;
    late PantryEntry pantryEntryCustomFood;
    late PantryEntry pantryEntryEdamamFood;
    late FoodService foodService;

    setUp(() async {
      customFood = CustomFood(id: '7', name: 'Escargot');
      customFoodRepository = MockCustomFoodRepository();
      when(customFoodRepository.streamFood(customFood.toFoodReference())).thenAnswer((_) => Stream.value(customFood));
      when(customFoodRepository.fetchFood(customFood.toFoodReference())).thenAnswer((_) => Future.value(customFood));
      when(customFoodRepository.streamQuery(any)).thenAnswer((_) => Stream.value([customFood].build()));
      when(customFoodRepository.fetchQuery(any)).thenAnswer((_) => Future.value([customFood].build()));

      edamamFood = EdamamFood(id: '8', name: 'Toast Corners');
      edamamFoodRepository = MockEdamamFoodRepository();
      when(edamamFoodRepository.streamFood(edamamFood.toFoodReference())).thenAnswer((_) => Stream.value(edamamFood));
      when(edamamFoodRepository.fetchFood(edamamFood.toFoodReference())).thenAnswer((_) => Future.value(edamamFood));
      when(edamamFoodRepository.streamQuery(any)).thenAnswer((_) => Stream.value([edamamFood].build()));
      when(edamamFoodRepository.fetchQuery(any)).thenAnswer((_) => Future.value([edamamFood].build()));

      pantryRepository = MockPantryRepository();
      pantryEntryCustomFood =
          PantryEntry(id: '7', foodReference: customFood.toFoodReference(), sensitivity: Sensitivity.severe);
      pantryEntryEdamamFood =
          PantryEntry(id: '8', foodReference: edamamFood.toFoodReference(), sensitivity: Sensitivity.mild);
      when(pantryRepository.streamByFood(any)).thenAnswer((_) => Stream.value(null));
      when(pantryRepository.streamByFood(customFood.toFoodReference()))
          .thenAnswer((_) => Stream.value(pantryEntryCustomFood));
      when(pantryRepository.streamByFood(edamamFood.toFoodReference()))
          .thenAnswer((_) => Stream.value(pantryEntryEdamamFood));

      foodService = FoodService(
        edamamFoodRepository: edamamFoodRepository,
        customFoodRepository: customFoodRepository,
        pantryRepository: pantryRepository,
      );
    });

    test('adds PantryEntryReference to streamed food', () async {
      final streamedCustomFood = foodService.streamFood(customFood.toFoodReference());
      await expectLater(streamedCustomFood,
          emits(customFood.rebuild((b) => b..pantryEntryReference = pantryEntryCustomFood.toReference().toBuilder())));

      final streamedEdamamFood = foodService.streamFood(edamamFood.toFoodReference());
      await expectLater(streamedEdamamFood,
          emits(edamamFood.rebuild((b) => b..pantryEntryReference = pantryEntryEdamamFood.toReference().toBuilder())));
    });

    test('adds PantryEntryReference to fetched food', () async {
      final fetchedCustomFood = await foodService.fetchFood(customFood.toFoodReference());
      expect(fetchedCustomFood is CustomFood, true);
      expect(fetchedCustomFood,
          customFood.rebuild((b) => b..pantryEntryReference = pantryEntryCustomFood.toReference().toBuilder()));

      final fetchedEdamamFood = await foodService.fetchFood(edamamFood.toFoodReference());
      expect(fetchedEdamamFood is EdamamFood, true);
      expect(fetchedEdamamFood,
          edamamFood.rebuild((b) => b..pantryEntryReference = pantryEntryEdamamFood.toReference().toBuilder()));
    });

    test('adds PantryEntryReferences to streamed query', () async {
      final streamedQuery = foodService.streamQuery('a');
      await expectLater(
          streamedQuery,
          emits([
            customFood.rebuild((b) => b..pantryEntryReference = pantryEntryCustomFood.toReference().toBuilder()),
            edamamFood.rebuild((b) => b..pantryEntryReference = pantryEntryEdamamFood.toReference().toBuilder()),
          ]));
    });

    test('adds PantryEntryReferences to fetched query', () async {
      final fetchedQuery = await foodService.fetchQuery('a');
      expect(fetchedQuery, [
        customFood.rebuild((b) => b..pantryEntryReference = pantryEntryCustomFood.toReference().toBuilder()),
        edamamFood.rebuild((b) => b..pantryEntryReference = pantryEntryEdamamFood.toReference().toBuilder()),
      ]);
      expect(fetchedQuery[0] is CustomFood, true);
      expect(fetchedQuery[1] is EdamamFood, true);
    });

    test('updates food stream with latest pantry data', () async {
      final pantryEntryCustomFood =
          PantryEntry(id: '8', foodReference: customFood.toFoodReference(), sensitivity: Sensitivity.severe);
      final pantryEntryCustomFoodUpdated =
          PantryEntry(id: '8', foodReference: customFood.toFoodReference(), sensitivity: Sensitivity.none);
      when(pantryRepository.streamByFood(customFood.toFoodReference()))
          .thenAnswer((_) => Stream.fromIterable([pantryEntryCustomFood, pantryEntryCustomFoodUpdated]));
      await expectLater(
          foodService.streamFood(customFood.toFoodReference()),
          emitsInOrder([
            customFood.rebuild((b) => b.pantryEntryReference = pantryEntryCustomFood.toReference().toBuilder()),
            customFood.rebuild((b) => b.pantryEntryReference = pantryEntryCustomFoodUpdated.toReference().toBuilder()),
          ]));
    });
  });
}
