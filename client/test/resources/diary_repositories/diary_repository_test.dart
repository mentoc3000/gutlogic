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
    final mayo = EdamamFoodReference(id: 'mayo', name: 'Mayo');
    final mustard = EdamamFoodReference(id: 'mustard', name: 'Mustard');
    final ketchup = EdamamFoodReference(id: 'ketchup', name: 'Ketchup');

    setUp(() async {
      const name = 'Gas';
      const severity = Severity.mild;
      final datetime = DateTime.now().toUtc();
      final mealEntry1 = MealEntry(
        id: 'id1',
        datetime: datetime.subtract(const Duration(days: 1)),
        mealElements: [
          MealElement(id: 'meid0', foodReference: mayo),
          MealElement(id: 'meid1', foodReference: mustard),
        ].toBuiltList(),
      );
      final symptomEntry = SymptomEntry(
        id: 'id2',
        datetime: datetime,
        symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: name), severity: severity),
      );
      final mealEntry2 = MealEntry(
        id: 'id3',
        datetime: datetime.add(const Duration(days: 1)),
        mealElements: [
          MealElement(id: 'meid2', foodReference: mayo),
          MealElement(id: 'meid3', foodReference: ketchup),
        ].toBuiltList(),
      );
      diaryEntries = [symptomEntry, mealEntry1, mealEntry2].toBuiltList();

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
      expect(recentFoods, [ketchup, mayo, mustard].toBuiltList());
    });
  });
}
