import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryEntriesEvent extends Equatable {
  DiaryEntriesEvent([List props = const []]) : super(props);
}

class LoadDiaryEntries extends DiaryEntriesEvent {
  @override
  String toString() => 'LoadDiaryEntries';
}

class AddDiaryEntry extends DiaryEntriesEvent {
  final DiaryEntry diaryEntry;

  AddDiaryEntry(this.diaryEntry) : super([diaryEntry]);

  @override
  String toString() => 'AddDiaryEntry { todo: $diaryEntry }';
}

class UpdateDiaryEntry extends DiaryEntriesEvent {
  final DiaryEntry updatedDiaryEntry;

  UpdateDiaryEntry(this.updatedDiaryEntry) : super([updatedDiaryEntry]);

  @override
  String toString() => 'UpdateDiaryEntry { updatedDiaryEntry: $updatedDiaryEntry }';
}

class DeleteDiaryEntry extends DiaryEntriesEvent {
  final DiaryEntry diaryEntry;

  DeleteDiaryEntry(this.diaryEntry) : super([diaryEntry]);

  @override
  String toString() => 'DeleteDiaryEntry { todo: $diaryEntry }';
}

