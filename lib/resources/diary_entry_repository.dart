import 'dart:async';
import 'dummy_data.dart';
import '../models/diary_entry.dart';

class DiaryEntryRepository {

  Future<List<DiaryEntry>> fetchAllDiaryEntries() => Future(() => [Dummy.mealEntries[0],
                                                                   Dummy.bowelMovementEntries[0],
                                                                   Dummy.medicineEntries[0],
                                                                   Dummy.medicineEntries[1],
                                                                   Dummy.symptomEntries[0]]
  );

}