import 'package:equatable/equatable.dart';
import '../../models/food/food.dart';
import '../../models/pantry_entry.dart';
import '../../models/sensitivity.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class PantryEntryEvent extends Equatable {
  const PantryEntryEvent();

  @override
  List<Object> get props => [];
}

class Load extends PantryEntryEvent {
  final PantryEntry pantryEntry;

  const Load(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];

  @override
  String toString() => 'Load { id: ${pantryEntry.id} }';
}

class CreateAndStreamEntry extends PantryEntryEvent implements TrackedEvent {
  final Food food;

  const CreateAndStreamEntry(this.food);

  @override
  List<Object> get props => [food];

  @override
  String toString() => 'CreateAndStreamEntry { new PantryEntry }';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('create_pantry_entry');
}

class StreamEntry extends PantryEntryEvent {
  final PantryEntry pantryEntry;

  const StreamEntry(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];

  @override
  String toString() => 'StreamEntry { id: ${pantryEntry.id} }';
}

class Delete extends PantryEntryEvent implements TrackedEvent {
  const Delete();

  @override
  String toString() => 'Delete';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_pantry_entry');
}

class UpdateEntry extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final PantryEntry pantryEntry;

  const UpdateEntry(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];

  @override
  String toString() => 'Update { pantryEntryId: ${pantryEntry.id} }';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_pantry_entry');
}

class UpdateSensitivity extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final Sensitivity sensitivity;

  const UpdateSensitivity(this.sensitivity);

  @override
  List<Object> get props => [sensitivity];

  @override
  String toString() => 'UpdateSensitivity { newSensitivity: $sensitivity } }';

  @override
  void track(AnalyticsService analyticsService) =>
      analyticsService.logUpdateEvent('update_pantry_entry', 'sensitivity');
}

class UpdateNotes extends PantryEntryEvent with DebouncedEvent implements TrackedEvent {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object> get props => [notes];

  @override
  String toString() => 'UpdateNotes { newNotes: $notes } }';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_pantry_entry', 'notes');
}

class ThrowPantryEntryError extends PantryEntryEvent {
  final Object error;
  final StackTrace trace;

  const ThrowPantryEntryError({this.error, this.trace});

  @override
  List<Object> get props => [error, trace];

  @override
  String toString() => 'Throw { error: $error }';
}
