import 'package:gut_ai/models/meal.dart';

import 'database_bloc.dart';
import '../models/diary_entry.dart';
import '../resources/diary_entry_repository.dart';
import '../resources/id_service.dart';

class DiaryEntryBloc extends DatabaseBloc<DiaryEntry, DiaryEntryRepository> {
  final IdService idService;

  DiaryEntryBloc(DiaryEntryRepository diaryEntriesRepository, this.idService)
      : super(diaryEntriesRepository);

  MealEntry newMealEntry() {
    String id = idService.getId();
    String userId = idService.getUserId();
    return MealEntry.newEntry(id, userId);
  }

  BowelMovementEntry newBowelMovementEntry() {
    String id = idService.getId();
    String userId = idService.getUserId();
    return BowelMovementEntry.newEntry(id, userId);
  }

  DosesEntry newDosesEntry() {
    String id = idService.getId();
    String userId = idService.getUserId();
    return DosesEntry.newEntry(id, userId);
  }

  SymptomEntry newSymptomEntry() {
    String id = idService.getId();
    String userId = idService.getUserId();
    return SymptomEntry.newEntry(id, userId);
  }

}
