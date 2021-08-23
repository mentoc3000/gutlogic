import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';

abstract class PantryEntryEvent extends Equatable {
  const PantryEntryEvent();

  @override
  List<Object?> get props => [];
}

class Load extends PantryEntryEvent {
  final PantryEntry pantryEntry;
  final Food? food;

  const Load({required this.pantryEntry, this.food});

  @override
  List<Object?> get props => [pantryEntry, food];

  @override
  String toString() => 'Load { id: ${pantryEntry.userFoodDetailsId} }';
}

class CreateAndStreamEntry extends PantryEntryEvent implements TrackedEvent {
  final FoodReference foodReference;

  const CreateAndStreamEntry(this.foodReference);

  @override
  List<Object?> get props => [foodReference];

  @override
  String toString() => 'CreateAndStreamEntry { new PantryEntry }';

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_pantry_entry');
}

class StreamEntry extends PantryEntryEvent {
  final PantryEntry pantryEntry;

  const StreamEntry(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];

  @override
  String toString() => 'StreamEntry { id: ${pantryEntry.userFoodDetailsId} }';
}

class Delete extends PantryEntryEvent implements TrackedEvent {
  const Delete();

  @override
  String toString() => 'Delete';

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_pantry_entry');
}

class UpdateSensitivityLevel extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final SensitivityLevel sensitivityLevel;

  const UpdateSensitivityLevel(this.sensitivityLevel);

  @override
  List<Object?> get props => [sensitivityLevel];

  @override
  String toString() => 'UpdateSensitivity { newSensitivity: $sensitivityLevel } }';

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry', 'sensitivity_level');
}

class UpdateNotes extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];

  @override
  String toString() => 'UpdateNotes { newNotes: $notes } }';

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry', 'notes');
}

class ThrowPantryEntryError extends PantryEntryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowPantryEntryError({required this.report});

  factory ThrowPantryEntryError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowPantryEntryError(report: ErrorReport(error: error, trace: trace));
}
