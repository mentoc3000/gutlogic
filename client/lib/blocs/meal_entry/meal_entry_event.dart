import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../models/food/food.dart';
import '../../models/meal_element.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../diary_entry/diary_entry.dart';

abstract class MealEntryEvent extends Equatable {
  const MealEntryEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LoadMealEntry extends MealEntryEvent with LoadDiaryEntry {
  @override
  final MealEntry diaryEntry;

  const LoadMealEntry(this.diaryEntry);
}

class CreateAndStreamMealEntry extends MealEntryEvent with CreateAndStreamDiaryEntry implements TrackedEvent {
  const CreateAndStreamMealEntry();

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('create_meal_entry');
}

class StreamMealEntry extends MealEntryEvent with StreamDiaryEntry {
  @override
  final MealEntry diaryEntry;

  const StreamMealEntry(this.diaryEntry);
}

class DeleteMealEntry extends MealEntryEvent with DeleteDiaryEntry implements TrackedEvent {
  @override
  final MealEntry diaryEntry;

  const DeleteMealEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_meal_entry');
}

class UpdateMealEntry extends MealEntryEvent with UpdateDiaryEntry implements DebouncedEvent, TrackedEvent {
  @override
  final MealEntry diaryEntry;

  const UpdateMealEntry(this.diaryEntry);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_entry');
}

class UpdateMealEntryDateTime extends MealEntryEvent
    with UpdateDiaryEntryDateTime
    implements DebouncedEvent, TrackedEvent {
  @override
  final DateTime dateTime;

  const UpdateMealEntryDateTime(this.dateTime);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_entry', 'dateTime');
}

class UpdateMealEntryNotes extends MealEntryEvent with UpdateDiaryEntryNotes implements DebouncedEvent, TrackedEvent {
  @override
  final String notes;

  const UpdateMealEntryNotes(this.notes);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_entry', 'notes');
}

class AddMealElement extends MealEntryEvent implements TrackedEvent {
  final Food food;

  const AddMealElement(this.food);

  @override
  List<Object> get props => [food];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('create_meal_element');

  @override
  String toString() => 'AddMealElement { food: ${food.name} }';
}

class MoveMealElement extends MealEntryEvent implements TrackedEvent {
  final int fromIndex;
  final int toIndex;

  const MoveMealElement(this.fromIndex, this.toIndex);

  @override
  List<Object> get props => [fromIndex, toIndex];

  @override
  void track(AnalyticsService analyticsService) =>
      analyticsService.logUpdateEvent('update_meal_entry', 'move_meal_element');

  @override
  String toString() => 'MoveMealElement { fromIndex: $fromIndex, toIndex: $toIndex }';
}

class DeleteMealElement extends MealEntryEvent implements TrackedEvent {
  final MealEntry mealEntry;
  final MealElement mealElement;

  const DeleteMealElement({@required this.mealEntry, @required this.mealElement});

  @override
  List<Object> get props => [mealEntry, mealElement];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_meal_element');

  @override
  String toString() => 'RemoveMealElement { mealElementId: ${mealElement?.id} }';
}

class UndeleteMealElement extends MealEntryEvent {
  final MealEntry mealEntry;
  final MealElement mealElement;

  const UndeleteMealElement({@required this.mealEntry, @required this.mealElement});

  @override
  List<Object> get props => [mealEntry, mealElement];

  @override
  String toString() => 'UndeleteMealElement { mealElementId: ${mealElement.id} }';
}

class ThrowMealEntryError extends MealEntryEvent with ErrorEvent {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowMealEntryError({@required this.error, @required this.trace});
}
