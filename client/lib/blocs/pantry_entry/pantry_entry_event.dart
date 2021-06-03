import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../models/pantry/pantry_entry_reference.dart';
import '../../models/sensitivity.dart';
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
  String toString() => 'Load { id: ${pantryEntry.id} }';
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
  String toString() => 'StreamEntry { id: ${pantryEntry.id} }';
}

class StreamReference extends PantryEntryEvent {
  final PantryEntryReference pantryEntryReference;

  const StreamReference(this.pantryEntryReference);

  @override
  List<Object?> get props => [pantryEntryReference];

  @override
  String toString() => 'StreamId { id: ${pantryEntryReference.id} }';
}

class Delete extends PantryEntryEvent implements TrackedEvent {
  const Delete();

  @override
  String toString() => 'Delete';

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_pantry_entry');
}

class UpdateEntry extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final PantryEntry pantryEntry;

  const UpdateEntry(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];

  @override
  String toString() => 'Update { pantryEntryId: ${pantryEntry.id} }';

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry');
}

class UpdateSensitivity extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final Sensitivity sensitivity;

  const UpdateSensitivity(this.sensitivity);

  @override
  List<Object?> get props => [sensitivity];

  @override
  String toString() => 'UpdateSensitivity { newSensitivity: $sensitivity } }';

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry', 'sensitivity');
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
