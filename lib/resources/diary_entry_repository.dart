import 'dart:async';
import 'dummy_data.dart';
import '../models/diary_entry.dart';

class DiaryEntryRepository {

  List<DiaryEntry> entries;

  DiaryEntryRepository() {
    entries = [
      Dummy.mealEntries[0],
      Dummy.bowelMovementEntries[0],
      Dummy.dosesEntries[0],
      Dummy.symptomEntries[0]
    ];
  }

  Future<List<DiaryEntry>> fetchAllDiaryEntries() => Future(() => entries);

  void addEntry(DiaryEntry newEntry) => entries.add(newEntry);

  void addEntries(List<DiaryEntry> newEntries) => entries.addAll(newEntries);

  void removeEntry(DiaryEntry entry) => entries.remove(entry);

}