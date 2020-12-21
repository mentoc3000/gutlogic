import 'package:equatable/equatable.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../bloc_helpers.dart';

mixin DiaryEntryLoading on Equatable {}

mixin DiaryEntryLoaded on Equatable {
  DiaryEntry get diaryEntry;

  @override
  List<Object> get props => [diaryEntry];

  @override
  String toString() => 'DiaryEntryLoaded { diaryEntry: ${diaryEntry?.id} }';
}

mixin DiaryEntryError on Equatable implements ErrorRecorder {
  String get message;

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'DiaryEntryError { message: $message }';
}
