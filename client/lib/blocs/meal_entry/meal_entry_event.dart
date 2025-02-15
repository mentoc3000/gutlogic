import 'package:equatable/equatable.dart';

import '../../models/diary_entry/meal_entry.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/meal_element.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class MealEntryEvent extends Equatable {
  const MealEntryEvent();

  @override
  List<Object?> get props => [];
}

class LoadMealEntry extends MealEntryEvent with LoadDiaryEntry {
  @override
  final MealEntry diaryEntry;

  const LoadMealEntry(this.diaryEntry);
}

class CreateAndStreamMealEntry extends MealEntryEvent with CreateAndStreamDiaryEntry implements Tracked {
  const CreateAndStreamMealEntry();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_meal_entry');
}

class StreamMealEntry extends MealEntryEvent with StreamDiaryEntry {
  @override
  final MealEntry diaryEntry;

  const StreamMealEntry(this.diaryEntry);
}

class DeleteMealEntry extends MealEntryEvent with DeleteDiaryEntry implements Tracked {
  @override
  final MealEntry diaryEntry;

  const DeleteMealEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_meal_entry');
}

class UpdateMealEntry extends MealEntryEvent with UpdateDiaryEntry implements Tracked {
  @override
  final MealEntry diaryEntry;

  const UpdateMealEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_entry');
}

class UpdateMealEntryDateTime extends MealEntryEvent with UpdateDiaryEntryDateTime implements Tracked {
  @override
  final DateTime dateTime;

  const UpdateMealEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_entry', 'dateTime');
}

class UpdateMealEntryNotes extends MealEntryEvent with UpdateDiaryEntryNotes implements Tracked {
  @override
  final String notes;

  const UpdateMealEntryNotes(this.notes);

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_entry', 'notes');
}

class AddMealElement extends MealEntryEvent implements Tracked {
  final FoodReference foodReference;

  const AddMealElement(this.foodReference);

  @override
  List<Object?> get props => [foodReference];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_meal_element');
}

class MoveMealElement extends MealEntryEvent implements Tracked {
  final int fromIndex;
  final int toIndex;

  const MoveMealElement(this.fromIndex, this.toIndex);

  @override
  List<Object?> get props => [fromIndex, toIndex];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_entry', 'move_meal_element');
}

class DeleteMealElement extends MealEntryEvent implements Tracked {
  final MealEntry mealEntry;
  final MealElement mealElement;

  const DeleteMealElement({required this.mealEntry, required this.mealElement});

  @override
  List<Object?> get props => [mealEntry, mealElement];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_meal_element');
}

class UndeleteMealElement extends MealEntryEvent {
  final MealEntry mealEntry;
  final MealElement mealElement;

  const UndeleteMealElement({required this.mealEntry, required this.mealElement});

  @override
  List<Object?> get props => [mealEntry, mealElement];
}

class ThrowMealEntryError extends MealEntryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowMealEntryError({required this.report});

  factory ThrowMealEntryError.fromError({required dynamic error, required StackTrace trace}) {
    return ThrowMealEntryError(report: ErrorReport(error: error, trace: trace));
  }
}
