import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry_state.dart';

abstract class BowelMovementEntryState extends Equatable {
  @override
  List<Object> get props => [];
}

class BowelMovementEntryLoading extends BowelMovementEntryState with DiaryEntryLoading {}

class BowelMovementEntryLoaded extends BowelMovementEntryState with DiaryEntryLoaded {
  @override
  final DiaryEntry diaryEntry;

  BowelMovementEntryLoaded(this.diaryEntry);
}

class BowelMovementEntryError extends BowelMovementEntryState with DiaryEntryError, ErrorRecorder {
  @override
  final ErrorReport report;

  @override
  final String message;

  BowelMovementEntryError({@required this.message}) : report = null;

  BowelMovementEntryError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
