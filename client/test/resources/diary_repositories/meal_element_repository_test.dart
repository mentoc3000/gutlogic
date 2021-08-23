import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'meal_element_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, PantryService])
void main() {
  group('MealElementRepository', () {
    late String diaryEntryId;
    late MealElement mealElement1;
    late MealElement mealElement2;
    late MealEntry diaryEntry;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late MealElementRepository mealElementRepository;
    late MockPantryService pantryService;

    setUp(() {
      diaryEntryId = 'entry1Id';
      final dateTime = DateTime.now().toUtc();
      const notes = 'easy';
      final food = CustomFood(id: 'food1', name: 'Eggs');
      mealElement1 = MealElement(
        id: '$diaryEntryId#mealElement1',
        foodReference: food.toFoodReference(),
        quantity: Quantity.unweighed(amount: 2, unit: 'each'),
      );
      mealElement2 = MealElement(
        id: '$diaryEntryId#mealElement2',
        foodReference: CustomFoodReference(id: 'food2', name: 'Bread'),
        quantity: Quantity.unweighed(amount: 1, unit: 'slice'),
      );
      final mealElements = [mealElement1, mealElement2].build();
      diaryEntry = MealEntry(
        id: diaryEntryId,
        datetime: dateTime,
        mealElements: mealElements,
        notes: notes,
      );

      instance = FakeFirebaseFirestore();
      instance.collection('diary').doc(diaryEntryId).set({
        '\$': 'MealEntry',
        'mealElements': mealElements.map(serializers.serialize).toList(),
        'datetime': Timestamp.fromDate(dateTime),
        'notes': notes,
      });

      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userDiaryCollection).thenReturn(instance.collection('diary'));

      pantryService = MockPantryService();
      final pantryEntry = PantryEntry(
        userFoodDetailsId: 'pantry1',
        foodReference: food.toFoodReference(),
        sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
        notes: null,
      );
      when(pantryService.fetchByFood(any)).thenAnswer((_) async => pantryEntry);

      mealElementRepository = MealElementRepository(
        firestoreService: firestoreService,
        pantryService: pantryService,
      );
    });

    test('streams entry', () async {
      await expectLater(mealElementRepository.stream(mealElement1), emits(mealElement1));
    });

    test('creates mealElement with food', () async {
      final food = CustomFood(id: 'food1', name: 'Brownie');
      final foodReference = food.toFoodReference();
      final mealElement = await mealElementRepository.addNewMealElementTo(diaryEntry, food: food);
      expect(mealElement!.id.startsWith('$diaryEntryId#'), true);
      expect(mealElement.foodReference, foodReference);
      expect(mealElement.quantity, isNull);
      expect(mealElement.notes, isNull);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).length, 3);
    });

    test('adds a mealElement', () async {
      final mealElement3 = MealElement(
        id: '$diaryEntryId#mealElement3',
        foodReference: CustomFoodReference(id: 'food3', name: 'Bread'),
        quantity: Quantity.unweighed(amount: 1, unit: 'slice'),
      );
      final mealElement = await mealElementRepository.addMealElementTo(diaryEntry, mealElement: mealElement3);
      expect(mealElement!.id.startsWith('$diaryEntryId#'), true);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).length, 3);
    });

    test('deletes mealElement', () async {
      final retrievedEntryBefore = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntryBefore!['mealElements'] as List).length, 2);
      await mealElementRepository.delete(mealElement1);
      final retrievedEntryAfter = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntryAfter!['mealElements'] as List).length, 1);
      expect((retrievedEntryAfter['mealElements'] as List).first['id'], mealElement2.id);
    });

    test('updates mealElement', () async {
      const notes = 'new notes';
      final updatedMealElement = mealElement1.rebuild((b) => b..notes = notes);
      await mealElementRepository.update(updatedMealElement);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).first['notes'], notes);
    });

    test('updates quantity', () async {
      final quantity = Quantity.unweighed(amount: 3, unit: 'patties');
      await mealElementRepository.updateQuantity(mealElement1, quantity);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).first['quantity']['measure']['unit'], quantity.measure!.unit);
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await mealElementRepository.updateNotes(mealElement1, notes);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).first['notes'], notes);
    });
  });
}
