import 'package:equatable/equatable.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../resources/firebase/analytics_service.dart';

mixin LoadDiaryEntry on Equatable {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];
}

mixin CreateAndStreamDiaryEntry on Equatable {}

mixin StreamDiaryEntry on Equatable {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];
}

mixin DeleteDiaryEntry on Equatable implements Tracked {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];
}

mixin UpdateDiaryEntry on Equatable implements Tracked {
  DiaryEntry get diaryEntry;

  @override
  List<Object?> get props => [diaryEntry];
}

mixin UpdateDiaryEntryDateTime on Equatable implements Tracked {
  DateTime get dateTime;

  @override
  List<Object?> get props => [dateTime];
}

mixin UpdateDiaryEntryNotes on Equatable implements Tracked {
  String get notes;

  @override
  List<Object?> get props => [notes];
}
