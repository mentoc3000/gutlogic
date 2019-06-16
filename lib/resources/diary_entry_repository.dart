import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'repository_interfaces.dart';
import 'dummy_data.dart';
import '../models/diary_entry.dart';

class DiaryEntryRepository extends DatabaseRepository<DiaryEntry> {
  DiaryEntryRepository() {
    items = BuiltList<DiaryEntry>([
      Dummy.mealEntries[0],
      Dummy.bowelMovementEntries[0],
      Dummy.dosesEntries[0],
      Dummy.symptomEntries[0]
    ]);
  }
}
