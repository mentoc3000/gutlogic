import 'package:equatable/equatable.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../models/meal_element.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry_state.dart';

abstract class MealEntryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MealEntryLoading extends MealEntryState with DiaryEntryLoading {}

class MealEntryLoaded extends MealEntryState with DiaryEntryLoaded {
  @override
  final DiaryEntry diaryEntry;

  MealEntryLoaded(this.diaryEntry);
}

class MealElementDeleted extends MealEntryState {
  final MealEntry mealEntry;
  final MealElement mealElement;

  MealElementDeleted({required this.mealEntry, required this.mealElement});

  @override
  List<Object?> get props => [mealEntry, mealElement];
}

class MealEntryError extends MealEntryState with DiaryEntryError, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  MealEntryError({required this.message}) : report = null;

  MealEntryError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory MealEntryError.fromReport(ErrorReport report) =>
      MealEntryError.fromError(error: report.error, trace: report.trace);
}
