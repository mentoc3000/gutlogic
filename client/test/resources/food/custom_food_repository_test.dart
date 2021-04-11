import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:gutlogic/resources/food/custom_food_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('CustomFoodRepository', () {
    String customFoodId;
    CustomFoodReference foodReference;
    MockFirestoreInstance instance;
    CustomFoodRepository foodRepository;
    FirestoreService firestoreService;
    CustomFood food;

    setUp(() async {
      customFoodId = '7';
      const customFoodId2 = '8';
      food = CustomFood(id: customFoodId, name: 'Escargot');
      foodReference = food.toFoodReference();
      instance = MockFirestoreInstance();
      await instance.collection('foods').doc(customFoodId).set(serializers.serialize(food));
      await instance.collection('foods').doc(customFoodId2).set(serializers.serialize(food));
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.customFoodCollection).thenReturn(instance.collection('foods'));
      foodRepository = CustomFoodRepository(firestoreService: firestoreService);
    });

    test('fetches query', () async {
      final fetchedFoods = await foodRepository.fetchQuery(food.name);
      expect(fetchedFoods.length, 2);
    });

    test('fetches no food for empty query', () async {
      final fetchedFoods = await foodRepository.fetchQuery('');
      expect(fetchedFoods.length, 0);
    });

    test('fetches single food', () async {
      final fetchedFood = await foodRepository.fetchItem(foodReference);
      expect(fetchedFood, food);
    });

    test('streams query', () async {
      final fetchedFoods = await foodRepository.fetchQuery(food.name);
      await expectLater(foodRepository.streamQuery(food.name), emits(fetchedFoods));
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

class MockFirestoreService extends Mock implements FirestoreService {}
