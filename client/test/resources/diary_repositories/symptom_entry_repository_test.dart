import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('SymptomEntryRepository', () {
    String diaryEntryId;
    SymptomEntry diaryEntry;
    MockFirestoreInstance instance;
    FirestoreService firestoreService;
    SymptomEntryRepository repository;

    setUp(() {
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
      instance.collection('diary').doc(diaryEntryId).set({
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
      repository = SymptomEntryRepository(firestoreService: firestoreService);
    });

    test('streams entry', () async {
      await expectLater(repository.stream(diaryEntry), emits(diaryEntry));
    });

    test('streams entry by id', () async {
      await expectLater(repository.streamById(diaryEntryId), emits(diaryEntry));
    });

    test('creates entry', () async {
      final now = DateTime.now();
      final newEntry = await repository.createFrom(SymptomType(id: 'id', name: 'Gas'));
      expect(newEntry.datetime.difference(now).inSeconds < 1, true);
      expect(newEntry.symptom.severity, SymptomEntryRepository.defaultSeverity);
      expect(newEntry.notes, isNull);
    });

    test('creates entry from symptom type', () async {
      final now = DateTime.now();
      final symptomType = SymptomType(id: 'symptomType1', name: 'type');
      final newEntry = await repository.createFrom(symptomType);
      expect(newEntry.datetime.difference(now).inSeconds < 1, true);
      expect(newEntry.symptom.symptomType, symptomType);
      expect(newEntry.notes, isNull);
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
      expect(retrievedEntry['notes'], notes);
    });

    test('updates datetime', () async {
      final datetime = DateTime.now().toUtc();
      await repository.updateDateTime(diaryEntry, datetime);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['datetime'], Timestamp.fromDate(datetime));
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(diaryEntry, notes);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['notes'], notes);
    });

    test('updates severity', () async {
      const severity = Severity.intense;
      await repository.updateSeverity(diaryEntry, severity);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['symptom']['severity'], serializers.serializeWith(Severity.serializer, severity));
    });

    test('updates symptom type', () async {
      final symptomType = SymptomType(id: 'symptomType1', name: 'Bloat');
      await repository.updateSymptomType(diaryEntry, symptomType);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['symptom']['symptomType']['name'], symptomType.name);
    });

    test('updates symptom name', () async {
      const symptomName = 'Bloat';
      await repository.updateSymptomName(diaryEntry, symptomName);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['symptom']['symptomType']['name'], symptomName);
    });

    test('updates symptom', () async {
      final symptom = Symptom(symptomType: SymptomType(id: 'symptomType1', name: 'Bloat'), severity: Severity.intense);
      await repository.updateSymptom(diaryEntry, symptom);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry['symptom']['severity'], serializers.serializeWith(Severity.serializer, symptom.severity));
    });
  });
}
