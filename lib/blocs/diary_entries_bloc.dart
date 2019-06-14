import 'bloc_interfaces.dart';
import '../models/diary_entry.dart';
import '../resources/diary_entries_repository.dart';

class DiaryEntriesBloc extends DatabaseBloc<DiaryEntry, DiaryEntriesRepository> {
  DiaryEntriesBloc() : super(DiaryEntriesRepository());
}