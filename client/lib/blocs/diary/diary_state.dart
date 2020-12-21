import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class DiaryState extends Equatable {
  @override
  List<Object> get props => [];
}

class DiaryLoading extends DiaryState {
  @override
  String toString() => 'DiaryLoading';
}

class DiaryLoaded extends DiaryState {
  final BuiltList<DiaryEntry> diaryEntries;

  DiaryLoaded([this.diaryEntries]);

  @override
  List<Object> get props => [diaryEntries];

  @override
  String toString() => 'DiaryLoaded { DiaryEntries: ${diaryEntries.length} }';
}

class DiaryEntryDeleted extends DiaryState {
  final DiaryEntry diaryEntry;

  DiaryEntryDeleted(this.diaryEntry);

  @override
  List<Object> get props => [diaryEntry];

  @override
  String toString() => 'DiaryEntryDeleted { diaryEntry: ${diaryEntry.id} }';
}

class DiaryError extends DiaryState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  DiaryError({@required this.message}) : report = null;

  DiaryError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'DiaryError { message: $message }';
}
