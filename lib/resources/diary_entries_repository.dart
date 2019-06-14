import 'dart:async';
import 'dummy_data.dart';
import '../models/diary_entry.dart';

class DiaryEntriesRepository {

  List<DiaryEntry> entries;

  DiaryEntriesRepository() {
    entries = [
      Dummy.mealEntries[0],
      Dummy.bowelMovementEntries[0],
      Dummy.dosesEntries[0],
      Dummy.symptomEntries[0]
    ];
  }

  Future<List<DiaryEntry>> fetchAllDiaryEntries() => Future(() => entries);

  void insert(DiaryEntry newEntry) => entries.add(newEntry);

  void insertAll(List<DiaryEntry> newEntries) => entries.addAll(newEntries);

  void delete(DiaryEntry entry) => entries.remove(entry);

}