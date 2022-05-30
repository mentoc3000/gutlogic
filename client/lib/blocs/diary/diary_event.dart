import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../models/diary_entry/diary_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../models/diary_entry/symptom_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';

abstract class DiaryEvent extends Equatable {
  const DiaryEvent();

  @override
  List<Object?> get props => [];
}

class StreamAllDiary extends DiaryEvent {
  const StreamAllDiary();
}

class StreamRange extends DiaryEvent {
  final DateTime start;
  final DateTime end;

  const StreamRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class Load extends DiaryEvent {
  final BuiltList<DiaryEntry> diaryEntries;

  const Load({required this.diaryEntries});

  @override
  List<Object?> get props => [diaryEntries];
}

class Delete extends DiaryEvent implements Tracked {
  final DiaryEntry diaryEntry;

  const Delete(this.diaryEntry);

  @override
  List<Object?> get props => [diaryEntry];

  @override
  void track(AnalyticsService analytics) {
    if (diaryEntry is MealEntry) {
      analytics.logEvent('delete_meal_entry');
    }
    if (diaryEntry is BowelMovementEntry) {
      analytics.logEvent('delete_bowel_movement_entry');
    }
    if (diaryEntry is SymptomEntry) {
      analytics.logEvent('delete_symptom_entry');
    }
  }
}

class Undelete extends DiaryEvent {
  final DiaryEntry diaryEntry;

  const Undelete(this.diaryEntry);

  @override
  List<Object?> get props => [diaryEntry];
}

class ThrowDiaryError extends DiaryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowDiaryError({required this.report});

  factory ThrowDiaryError.fromError({required dynamic error, required StackTrace trace}) {
    return ThrowDiaryError(report: ErrorReport(error: error, trace: trace));
  }
}
