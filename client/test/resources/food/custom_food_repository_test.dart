import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'custom_food_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, PantryRepository])
void main() {
  group('CustomFoodRepository', () {
    late CustomFoodReference foodReference;
    late MockFirestoreInstance instance;
    late CustomFoodRepository foodRepository;
    late MockFirestoreService firestoreService;
    late MockPantryRepository pantryRepository;
    late PantryEntry pantryEntry;
    late CustomFood food;

    setUp(() async {
      food = CustomFood(id: '7', name: 'Escargot');
      final food2 = CustomFood(id: '8', name: 'Escargot');
      foodReference = food.toFoodReference();

      instance = MockFirestoreInstance();
      await instance.collection('foods').doc(food.id).set(serializers.serialize(food) as Map<String, dynamic>);
      await instance.collection('foods').doc(food2.id).set(serializers.serialize(food2) as Map<String, dynamic>);

      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.customFoodCollection).thenReturn(instance.collection('foods'));

      pantryRepository = MockPantryRepository();
      pantryEntry = PantryEntry(id: 'id', foodReference: foodReference, sensitivity: Sensitivity.severe);
      final pantryEntry2 =
          PantryEntry(id: 'id2', foodReference: food2.toFoodReference(), sensitivity: Sensitivity.mild);
      when(pantryRepository.streamByFood(any)).thenAnswer((_) => Stream.value(null));
      when(pantryRepository.streamByFood(foodReference)).thenAnswer((_) => Stream.value(pantryEntry));
      when(pantryRepository.streamByFood(food2.toFoodReference()))
          .thenAnswer((realInvocation) => Stream.value(pantryEntry2));

      foodRepository = CustomFoodRepository(firestoreService: firestoreService, pantryRepository: pantryRepository);
    });

    test('fetches query', () async {
      final fetchedFoods = await foodRepository.fetchQuery(food.name);
      expect(fetchedFoods.length, 2);
    });

    test('fetches no foods for empty query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('');
      expect(fetchedFoods.length, 0);
    });

    test('fetches no foods for matchless query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('tacos');
      expect(fetchedFoods.length, 0);
    });

    test('fetches single food with pantry entry', () async {
      final fetchedFood = await foodRepository.fetchFood(foodReference);
      expect(fetchedFood!.pantryEntryReference, pantryEntry.toReference());
    });

    test('updates food stream with latest pantry data', () async {
      final pantryEntry1 = PantryEntry(id: 'id', foodReference: foodReference, sensitivity: Sensitivity.severe);
      final pantryEntry2 = PantryEntry(id: 'id', foodReference: foodReference, sensitivity: Sensitivity.mild);
      when(pantryRepository.streamByFood(foodReference))
          .thenAnswer((_) => Stream.fromIterable([pantryEntry1, pantryEntry2]));
      await expectLater(
          foodRepository.streamFood(food.toFoodReference()),
          emitsInOrder([
            food.rebuild((b) => b.pantryEntryReference = pantryEntry1.toReference().toBuilder()),
            food.rebuild((b) => b.pantryEntryReference = pantryEntry2.toReference().toBuilder()),
          ]));
    });

    test('streams query', () async {
      final fetchedFoods = await foodRepository.fetchQuery(food.name);
      await expectLater(foodRepository.streamQuery(food.name), emits(fetchedFoods));
    });

    test('streams no foods for matchless query', () async {
      await expectLater(foodRepository.streamQuery('tacos'), emits(<CustomFood>[].build()));
    });

    test('adds a food', () async {
      await foodRepository.add(name: 'tacos');
      final entries = await instance.collection('foods').get();
      expect(entries.docs.length, 3);
    });

    test('does not add a blank food', () async {
      await foodRepository.add(name: '');
      final entries = await instance.collection('foods').get();
      expect(entries.docs.length, 2);
    });

    test('deletes a food', () async {
      await foodRepository.delete(food);
      final entries = await instance.collection('foods').get();
      expect(entries.docs.length, 1);
    });
  });
}
