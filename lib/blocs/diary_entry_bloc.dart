import 'database_bloc.dart';
import '../models/diary_entry.dart';
import '../resources/diary_entry_repository.dart';

class DiaryEntryBloc
    extends DatabaseBloc<DiaryEntry, DiaryEntryRepository> {
  DiaryEntryBloc(DiaryEntryRepository diaryEntriesRepository)
      : super(diaryEntriesRepository);
}
