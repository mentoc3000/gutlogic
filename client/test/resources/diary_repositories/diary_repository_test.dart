import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'diary_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, CrashlyticsService])
void main() {
  group('DiaryRepository', () {
    late BuiltList<DiaryEntry> diaryEntries;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late DiaryRepository repository;
    final datetime = DateTime.now().toUtc();
    final mayo = EdamamFoodReference(id: 'mayo', name: 'Mayo');
    final mustard = EdamamFoodReference(id: 'mustard', name: 'Mustard');
    final ketchup = EdamamFoodReference(id: 'ketchup', name: 'Ketchup');
    final bread = EdamamFoodReference(id: 'bread', name: 'Bread');

    setUp(() async {
      const name = 'Gas';
      const severity = Severity.mild;
      final mealEntry1 = MealEntry(
        id: 'id1',
        datetime: datetime,
        mealElements: [
          MealElement(id: 'meid0', foodReference: mayo),
          MealElement(id: 'meid1', foodReference: mustard),
        ].toBuiltList(),
      );
      final symptomEntry = SymptomEntry(
        id: 'id2',
        datetime: datetime.subtract(const Duration(days: 1)),
        symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: name), severity: severity),
      );
      final mealEntry2 = MealEntry(
        id: 'id3',
        datetime: datetime.subtract(const Duration(days: 2)),
        mealElements: [
          MealElement(id: 'meid2', foodReference: mayo),
          MealElement(id: 'meid3', foodReference: ketchup),
        ].toBuiltList(),
      );
      final mealEntry3 = MealEntry(
        id: 'id4',
        datetime: datetime.subtract(const Duration(days: 3)),
        mealElements: [
          MealElement(id: 'meid4', foodReference: bread),
        ].toBuiltList(),
      );
      diaryEntries = [symptomEntry, mealEntry1, mealEntry2, mealEntry3].toBuiltList();

      instance = FakeFirebaseFirestore();
      await instance
          .collection('diary')
          .doc(symptomEntry.id)
          .set(serializers.serialize(symptomEntry) as Map<String, dynamic>);
      await instance
          .collection('diary')
          .doc(mealEntry1.id)
          .set(serializers.serialize(mealEntry1) as Map<String, dynamic>);
      await instance
          .collection('diary')
          .doc(mealEntry2.id)
          .set(serializers.serialize(mealEntry2) as Map<String, dynamic>);
      await instance
          .collection('diary')
          .doc(mealEntry3.id)
          .set(serializers.serialize(mealEntry3) as Map<String, dynamic>);

      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userDiaryCollection).thenReturn(instance.collection('diary'));
      repository = DiaryRepository(firestoreService: firestoreService, crashlytics: MockCrashlyticsService());
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits(diaryEntries));
    });

    test('removes corrupt entry', () async {
      // Add corrupt diary entry
      const corruptDiaryEntryId = 'entry2Id';
      await instance.collection('diary').doc(corruptDiaryEntryId).set({
        '\$': 'SymptomEntry',
        'symptom': {
          'symptomType': {
            'name': 'name',
          },
          'severity': 'abc', // severity should be a number
        },
        'datetime': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // returns good diary entries
      await expectLater(repository.streamAll(), emits(diaryEntries));
    });

    test('gets recent foods', () async {
      final recentFoods = await repository.recentFoods();
      expect(recentFoods, [mustard, mayo, ketchup, bread].toBuiltList());
    });

    test('gets recent foods in range', () async {
      final recentFoods = await repository.recentFoods(
        start: datetime.subtract(const Duration(days: 2, hours: 6)),
        end: datetime.subtract(const Duration(days: 1, hours: 6)),
      );
      expect(recentFoods, [ketchup, mayo].toBuiltList());
    });
  });
}
