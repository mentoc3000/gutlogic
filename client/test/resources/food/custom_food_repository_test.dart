import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'custom_food_repository_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  group('CustomFoodRepository', () {
    late FakeFirebaseFirestore instance;
    late CustomFoodRepository foodRepository;
    late FirestoreService firestoreService;
    late CustomFood food;

    setUp(() async {
      food = CustomFood(id: '7', name: 'Escargot');
      final food2 = CustomFood(id: '8', name: 'Escargot');

      instance = FakeFirebaseFirestore();
      await instance.collection('foods').doc(food.id).set(serializers.serialize(food) as Map<String, dynamic>);
      await instance.collection('foods').doc(food2.id).set(serializers.serialize(food2) as Map<String, dynamic>);

      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.customFoodCollection).thenReturn(instance.collection('foods'));

      foodRepository = CustomFoodRepository(firestoreService: firestoreService);
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
