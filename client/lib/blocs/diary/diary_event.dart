import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../models/diary_entry/diary_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../models/diary_entry/symptom_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class DiaryEvent extends Equatable {
  const DiaryEvent();

  @override
  List<Object> get props => [];
}

class StreamAll extends DiaryEvent {
  const StreamAll();

  @override
  String toString() => 'StreamAll';
}

class StreamRange extends DiaryEvent {
  final DateTime start;
  final DateTime end;

  const StreamRange({@required this.start, this.end});

  @override
  List<Object> get props => [start, end];

  @override
  String toString() => 'StreamRange { start: $start, end: $end }';
}

class Load extends DiaryEvent {
  final Iterable<DiaryEntry> diaryEntries;

  const Load({@required this.diaryEntries});

  @override
  List<Object> get props => [diaryEntries];

  @override
  String toString() => 'LoadEntries { diaryEntries: ${diaryEntries.length}}';
}

class Delete extends DiaryEvent implements TrackedEvent {
  final DiaryEntry diaryEntry;

  const Delete(this.diaryEntry);

  @override
  List<Object> get props => [diaryEntry];

  @override
  void track(AnalyticsService analyticsService) {
    if (diaryEntry is MealEntry) {
      analyticsService.logDeleteMealEntry();
    }
    if (diaryEntry is BowelMovementEntry) {
      analyticsService.logDeleteBowelMovementEntry();
    }
    if (diaryEntry is SymptomEntry) {
      analyticsService.logDeleteSymptomEntry();
    }
  }

  @override
  String toString() => 'Delete { id: ${diaryEntry.id} }';
}

class Undelete extends DiaryEvent {
  final DiaryEntry diaryEntry;

  const Undelete(this.diaryEntry);

  @override
  List<Object> get props => [diaryEntry];
}

class Throw extends DiaryEvent {
  final dynamic error;
  final StackTrace trace;

  const Throw({@required this.error, @required this.trace});

  @override
  List<Object> get props => [error, trace];

  @override
  String toString() => 'Throw { error: $error }';
}
