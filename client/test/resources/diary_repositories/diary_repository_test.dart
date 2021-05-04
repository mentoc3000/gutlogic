import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'diary_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, CrashlyticsService])
void main() {
  group('DiaryRepository', () {
    late String diaryEntryId;
    late SymptomEntry diaryEntry;
    late MockFirestoreInstance instance;
    late FirestoreService firestoreService;
    late DiaryRepository repository;

    setUp(() async {
      diaryEntryId = 'entry1Id';
      const name = 'Gas';
      const severity = Severity.mild;
      final dateTime = DateTime.now().toUtc();
      const notes = 'easy';
      diaryEntry = SymptomEntry(
        id: diaryEntryId,
        datetime: dateTime,
        symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: name), severity: severity),
        notes: notes,
      );
      instance = MockFirestoreInstance();
      await instance.collection('diary').doc(diaryEntryId).set({
        '\$': 'SymptomEntry',
        'symptom': {
          'symptomType': {
            'id': 'symptomType1',
            'name': name,
          },
          'severity': serializers.serializeWith(Severity.serializer, severity),
        },
        'datetime': Timestamp.fromDate(dateTime),
        'notes': notes,
      });
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userDiaryCollection).thenReturn(instance.collection('diary'));
      repository = DiaryRepository(firestoreService: firestoreService, crashlytics: MockCrashlyticsService());
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits([diaryEntry].build()));
    });

    test('streams range', () async {
      final start = diaryEntry.datetime.subtract(const Duration(days: 3));
      final end = diaryEntry.datetime.add(const Duration(days: 1));
      await expectLater(repository.streamRange(start, end), emits(diaryEntry));
    }, skip: 'unimplemented');

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

      // returns one good diary entry
      await expectLater(repository.streamAll(), emits([diaryEntry].build()));
    });
  });
}
