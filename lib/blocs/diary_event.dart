import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/diary_entry.dart';

@immutable
abstract class DiaryEvent extends Equatable {
  DiaryEvent([List props = const []]) : super(props);
}

class LoadDiary extends DiaryEvent {
  @override
  String toString() => 'LoadDiary';
}

class AddDiaryEntry extends DiaryEvent {
  final DiaryEntry diaryEntry;

  AddDiaryEntry(this.diaryEntry) : super([diaryEntry]);

  @override
  String toString() => 'AddDiaryEntry { todo: $diaryEntry }';
}

class UpdateDiaryEntry extends DiaryEvent {
  final DiaryEntry updatedDiaryEntry;

  UpdateDiaryEntry(this.updatedDiaryEntry) : super([updatedDiaryEntry]);

  @override
  String toString() => 'UpdateDiaryEntry { updatedDiaryEntry: $updatedDiaryEntry }';
}

class DeleteDiaryEntry extends DiaryEvent {
  final DiaryEntry diaryEntry;

  DeleteDiaryEntry(this.diaryEntry) : super([diaryEntry]);

  @override
  String toString() => 'DeleteDiaryEntry { todo: $diaryEntry }';
}

