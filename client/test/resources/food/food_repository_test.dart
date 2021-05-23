import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/resources/food/food_repository.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'food_repository_test.mocks.dart';

@GenerateMocks([PantryRepository])
void main() {
  group('FoodRepository', () {
    late MockPantryRepository pantryRepository;
    late List<PantryEntry> pantryEntries;
    late List<CustomFood> foods;
    late List<CustomFood> foodsWithPantryRefs;

    setUp(() async {
      pantryRepository = MockPantryRepository();
      when(pantryRepository.streamByFood(any)).thenAnswer((_) => Stream.value(null));
      foods = [
        CustomFood(id: '1', name: 'Tomato'),
        CustomFood(id: '2', name: 'Lettuce'),
        CustomFood(id: '3', name: 'Bacon')
      ];
      pantryEntries = [
        PantryEntry(id: '1', foodReference: foods[0].toFoodReference(), sensitivity: Sensitivity.none),
        PantryEntry(id: '2', foodReference: foods[1].toFoodReference(), sensitivity: Sensitivity.moderate)
      ];
      foodsWithPantryRefs = [
        foods[0].rebuild((b) => b.pantryEntryReference = pantryEntries[0].toReference().toBuilder()),
        foods[1].rebuild((b) => b.pantryEntryReference = pantryEntries[1].toReference().toBuilder()),
        foods[2],
      ];
    });

    test('merges pantry entry stream with updated food stream', () {
      for (var pantryEntry in pantryEntries) {
        when(pantryRepository.streamByFood(pantryEntry.foodReference)).thenAnswer((_) => Stream.value(pantryEntry));
      }
      final modifiedFood = foods[0].rebuild((b) => b.measures = [Measure(unit: 'each')].toBuiltList().toBuilder());
      final foodStream = Stream.fromIterable([foods[0], modifiedFood]);
      expect(
          mergePantryEntryStream(pantryRepository: pantryRepository, foodStream: foodStream),
          emits(
            modifiedFood.rebuild((b) => b.pantryEntryReference = pantryEntries[0].toReference().toBuilder()),
          ));
    });

    test('merges updated pantry entry stream with food stream', () {
      final modifiedPantryEntry = pantryEntries[0].rebuild((b) => b.sensitivity = Sensitivity.severe);
      when(pantryRepository.streamByFood(pantryEntries[0].foodReference))
          .thenAnswer((_) => Stream.fromIterable([pantryEntries[0], modifiedPantryEntry]));
      final foodStream = Stream.value(foods[0]);
      expect(
          mergePantryEntryStream(pantryRepository: pantryRepository, foodStream: foodStream),
          emitsInOrder([
            foods[0].rebuild((b) => b.pantryEntryReference = pantryEntries[0].toReference().toBuilder()),
            foods[0].rebuild((b) => b.pantryEntryReference = modifiedPantryEntry.toReference().toBuilder()),
          ]));
    });

    test('merges pantry entry stream with foods stream', () {
      for (var pantryEntry in pantryEntries) {
        when(pantryRepository.streamByFood(pantryEntry.foodReference)).thenAnswer((_) => Stream.value(pantryEntry));
      }
      final foodStream = Stream.value(foods);
      expect(mergePantryEntryStreams(pantryRepository: pantryRepository, foodStream: foodStream),
          emits(foodsWithPantryRefs));
    });

    test('returns empty food iterable', () {
      expect(mergePantryEntryStreams(pantryRepository: pantryRepository, foodStream: Stream.value(<CustomFood>[])),
          emits(<CustomFood>[].build()));
    });
  });
}
