import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry_state.dart';

abstract class SymptomEntryState extends Equatable {
  @override
  List<Object> get props => [];
}

class SymptomEntryLoading extends SymptomEntryState with DiaryEntryLoading {}

class SymptomEntryLoaded extends SymptomEntryState with DiaryEntryLoaded {
  @override
  final DiaryEntry diaryEntry;

  SymptomEntryLoaded(this.diaryEntry);
}

class SymptomEntryError extends SymptomEntryState with DiaryEntryError, ErrorRecorder {
  @override
  final ErrorReport report;

  @override
  final String message;

  SymptomEntryError({@required this.message}) : report = null;

  SymptomEntryError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
