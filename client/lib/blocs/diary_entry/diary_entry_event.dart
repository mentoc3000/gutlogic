import 'package:equatable/equatable.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

mixin LoadDiaryEntry on Equatable {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];

  @override
  String toString() => 'Load { id: ${diaryEntry.id} }';
}

mixin CreateAndStreamDiaryEntry on Equatable {}

mixin StreamDiaryEntry on Equatable {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];

  @override
  String toString() => 'StreamEntry { id: ${diaryEntry.id} }';
}

mixin DeleteDiaryEntry on Equatable implements Tracked {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];

  @override
  String toString() => 'Delete { diaryEntryId: ${diaryEntry.id} }';
}

mixin UpdateDiaryEntry on Equatable implements DebouncedEvent, Tracked {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];

  @override
  String toString() => 'Update { diaryEntryId: ${diaryEntry.id} }';
}

mixin UpdateDiaryEntryDateTime on Equatable implements DebouncedEvent, Tracked {
  DateTime get dateTime;

  @override
  List<Object?> get props => [dateTime];

  @override
  String toString() => 'UpdateDateTime { newDateTime: $dateTime } }';
}

mixin UpdateDiaryEntryNotes on Equatable implements DebouncedEvent, Tracked {
  String get notes;

  @override
  List<Object?> get props => [notes];

  @override
  String toString() => 'UpdateNotes { newNotes: $notes } }';
}
