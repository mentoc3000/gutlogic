import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/irritant.dart';
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
  final BuiltList<Irritant>? irritants;

  const Load({required this.pantryEntry, required this.food, required this.irritants});

  @override
  List<Object?> get props => [pantryEntry, food, irritants];
}

class CreateAndStreamEntry extends PantryEntryEvent implements Tracked {
  final FoodReference foodReference;

  const CreateAndStreamEntry(this.foodReference);

  @override
  List<Object?> get props => [foodReference];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_pantry_entry');
}

class StreamEntry extends PantryEntryEvent {
  final PantryEntry pantryEntry;

  const StreamEntry(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];
}

class Delete extends PantryEntryEvent implements Tracked {
  const Delete();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_pantry_entry');
}

class UpdateSensitivityLevel extends PantryEntryEvent implements Tracked {
  final SensitivityLevel sensitivityLevel;

  const UpdateSensitivityLevel(this.sensitivityLevel);

  @override
  List<Object?> get props => [sensitivityLevel];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry', 'sensitivity_level');
}

class UpdateNotes extends PantryEntryEvent implements Tracked {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_pantry_entry', 'notes');
}

class ThrowPantryEntryError extends PantryEntryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowPantryEntryError({required this.report});

  factory ThrowPantryEntryError.fromError({required dynamic error, required StackTrace trace}) {
    return ThrowPantryEntryError(report: ErrorReport(error: error, trace: trace));
  }
}
