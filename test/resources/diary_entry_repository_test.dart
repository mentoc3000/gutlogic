import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:gut_ai/resources/diary_entry_repository.dart';
import 'package:gut_ai/models/diary_entry.dart';

void main() {
  group('Diary Entry Repository', () {
    DiaryEntryRepository diaryEntryRepository;

    setUp(() {
      diaryEntryRepository = DiaryEntryRepository();
    });

    test('fetches all diary entries', () async {
      BuiltList<DiaryEntry> diaryEntries =
          await diaryEntryRepository.fetchAll();
      expect(diaryEntries.length, 4);
    });

    test('inserts a diary entry', () async {
      BowelMovementEntry newBM = BowelMovementEntry.fromBuilder((b) => b
        ..id = 'Dummy005'
        ..dateTime = DateTime.now()
        ..bowelMovement.type = 3
        ..bowelMovement.volume = 4
        ..notes = '');
      diaryEntryRepository.insert(newBM);
      BuiltList<DiaryEntry> diaryEntries =
          await diaryEntryRepository.fetchAll();
      expect(diaryEntries.contains(newBM), true);
    });

    test('deletes a diary entry', () async {
      BuiltList<DiaryEntry> diaryEntries =
          await diaryEntryRepository.fetchAll();
      DiaryEntry firstEntry = diaryEntries.first;
      diaryEntryRepository.delete(firstEntry.id);
      diaryEntries = await diaryEntryRepository.fetchAll();
      expect(diaryEntries.contains(firstEntry), false);
    });

    test('upsert inserts a diary entry', () async {
      BowelMovementEntry newBM = BowelMovementEntry.fromBuilder((b) => b
        ..id = 'Dummy005'
        ..dateTime = DateTime.now()
        ..bowelMovement.type = 3
        ..bowelMovement.volume = 4
        ..notes = '');
      diaryEntryRepository.upsert(newBM);
      BuiltList<DiaryEntry> diaryEntries =
          await diaryEntryRepository.fetchAll();
      expect(diaryEntries.contains(newBM), true);
    });

    test('upsert updates a diary entry', () async {
      BowelMovementEntry bm = BowelMovementEntry.fromBuilder((b) => b
        ..id = 'Dummy005'
        ..dateTime = DateTime.now()
        ..bowelMovement.type = 3
        ..bowelMovement.volume = 4
        ..notes = '');
      diaryEntryRepository.insert(bm);
      BowelMovementEntry newBM = bm.rebuild((b) => b..notes = 'Bad');
      diaryEntryRepository.upsert(newBM);
      BuiltList<DiaryEntry> diaryEntries =
          await diaryEntryRepository.fetchAll();
      expect(diaryEntries.contains(bm), false);
      expect(diaryEntries.contains(newBM), true);
    });
  });
}
