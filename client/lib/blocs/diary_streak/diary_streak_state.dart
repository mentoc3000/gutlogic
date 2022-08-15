import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class DiaryStreakState extends Equatable {
  const DiaryStreakState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class DiaryStreakLoading extends DiaryStreakState {
  const DiaryStreakLoading();
}

class DiaryStreakLoaded extends DiaryStreakState {
  final BuiltMap<DateTime, int> diaryStreak;

  const DiaryStreakLoaded(this.diaryStreak);

  @override
  List<Object?> get props => [diaryStreak];
}

class DiaryStreakError extends DiaryStreakState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  DiaryStreakError({required this.message}) : report = null;

  DiaryStreakError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory DiaryStreakError.fromReport(ErrorReport report) =>
      DiaryStreakError.fromError(error: report.error, trace: report.trace);
}
