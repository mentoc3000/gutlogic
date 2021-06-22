import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'bowel_movement_entry_repository_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  group('BowelMovementEntryRepository', () {
    late String diaryEntryId;
    late BowelMovementEntry diaryEntry;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late BowelMovementEntryRepository repository;

    setUp(() {
      diaryEntryId = 'entry1Id';
      const type = 3;
      const volume = 4;
      final dateTime = DateTime.now().toUtc();
      const notes = 'easy';
      diaryEntry = BowelMovementEntry(
        id: diaryEntryId,
        datetime: dateTime,
        bowelMovement: BowelMovement(type: type, volume: volume),
        notes: notes,
      );
      instance = FakeFirebaseFirestore();
      instance.collection('diary').doc(diaryEntryId).set({
        '\$': 'BowelMovementEntry',
        'bowelMovement': {
          'type': type,
          'volume': volume,
        },
        'datetime': Timestamp.fromDate(dateTime),
        'notes': notes,
      });
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userDiaryCollection).thenReturn(instance.collection('diary'));
      repository = BowelMovementEntryRepository(firestoreService: firestoreService);
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
      expect(newEntry.bowelMovement, BowelMovementEntryRepository.initialBowelMovementValue);
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

    test('updates type', () async {
      const type = 3;
      await repository.updateType(diaryEntry, type);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry!['bowelMovement']['type'], type);
    });

    test('updates volume', () async {
      const volume = 3;
      await repository.updateVolume(diaryEntry, volume);
      final retrievedEntry = (await instance.collection('diary').doc(diaryEntryId).get()).data();
      expect(retrievedEntry!['bowelMovement']['volume'], volume);
    });
  });
}
