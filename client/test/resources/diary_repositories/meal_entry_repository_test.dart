import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'meal_entry_repository_test.mocks.dart';

@GenerateMocks([MealElementRepository, FirestoreService])
void main() {
  group('MealEntryRepository', () {
    late String diaryEntryId;
    late MealElement mealElement1;
    late MealElement mealElement2;
    late MealEntry diaryEntry;
    late FakeFirebaseFirestore instance;
    late MockFirestoreService firestoreService;
    late MealEntryRepository repository;
    late MockMealElementRepository mealElementRepository;

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
        foodReference: CustomFoodReference(
          id: 'food2',
          name: 'Bread',
        ),
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

      mealElementRepository = MockMealElementRepository();
      when(mealElementRepository.addNewMealElementTo(any, food: anyNamed('food')))
          .thenAnswer((_) async => mealElement1);

      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userDiaryCollection).thenReturn(instance.collection('diary'));

      repository = MealEntryRepository(
        firestoreService: firestoreService,
        mealElementRepository: mealElementRepository,
      );
    });

    test('streams entry', () async {
      await expectLater(repository.stream(diaryEntry), emits(diaryEntry));
    });

    test('streams entry by id', () async {
      await expectLater(repository.streamById(diaryEntryId), emits(diaryEntry));
    });

    test('creates entry', () async {
      final now = DateTime.now();
      final newEntry = await repository.create();
      expect(newEntry!.datetime.difference(now).inSeconds < 1, true);
      expect(newEntry.notes, isNull);
      expect(newEntry.mealElements, isEmpty);
    });

    test('deletes entry by id', () async {
      final entriesBeforeDeletion = await instance.collection('diary').get();
      expect(entriesBeforeDeletion.docs.isEmpty, false);
      await repository.deleteById(diaryEntryId);
      final entriesAfterDeletion = await instance.collection('diary').get();
      expect(entriesAfterDeletion.docs.isEmpty, true);
    });

    test('deletes entry', () async {
      final entriesBeforeDeletion = await instance.collection('diary').get();
      expect(entriesBeforeDeletion.docs.isEmpty, false);
      await repository.delete(diaryEntry);
      final entriesAfterDeletion = await instance.collection('diary').get();
      expect(entriesAfterDeletion.docs.isEmpty, true);
    });

    test('updates entry', () async {
      const notes = 'new notes';
      final updatedDiaryEntry = diaryEntry.rebuild((b) => b..notes = notes);
      await repository.updateEntry(updatedDiaryEntry);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry!['notes'], notes);
    });

    test('updates datetime', () async {
      final datetime = DateTime.now().toUtc();
      await repository.updateDateTime(diaryEntry, datetime);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry!['datetime'], Timestamp.fromDate(datetime));
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(diaryEntry, notes);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry!['notes'], notes);
    });

    test('add mealElement', () async {
      final newFood = CustomFood(id: 'newfood', name: 'Pepper');
      await repository.createMealElement(diaryEntry, newFood);
      verify(mealElementRepository.addNewMealElementTo(any, food: anyNamed('food'))).called(1);
    });

    test('removes mealElement', () async {
      await repository.removeMealElement(diaryEntry, mealElement1);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntry!['mealElements'] as List).length, 1);
      expect((retrievedEntry['mealElements'] as List).first['id'], mealElement2.id);
    });

    test('reorders mealElements', () async {
      final retrievedEntryBefore = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntryBefore!['mealElements'] as List)[0]['id'], mealElement1.id);
      expect((retrievedEntryBefore['mealElements'] as List)[1]['id'], mealElement2.id);
      await repository.reorderMealElement(diaryEntry, 0, 1);
      final retrievedEntryAfter = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect((retrievedEntryAfter!['mealElements'] as List)[0]['id'], mealElement2.id);
      expect((retrievedEntryAfter['mealElements'] as List)[1]['id'], mealElement1.id);
    });
  });
}
