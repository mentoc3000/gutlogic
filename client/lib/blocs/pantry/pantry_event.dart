import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

export '../searchable/searchable_event.dart';

abstract class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class StreamAllPantry extends PantryEvent with StreamAll {
  const StreamAllPantry();
}

class LoadPantry extends PantryEvent with LoadSearchables {
  @override
  final BuiltList<PantryEntry> items;

  const LoadPantry({required this.items});
}

class StreamPantryQuery extends PantryEvent with StreamQuery implements Tracked {
  @override
  final String query;

  const StreamPantryQuery(this.query);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('pantry_search');
}

class DeletePantryEntry extends PantryEvent implements Tracked {
  final PantryEntry pantryEntry;

  const DeletePantryEntry(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];

  @override
  String toString() => 'Delete { id: ${pantryEntry.userFoodDetailsId} }';

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_pantry_entry');
}

class UndeletePantryEntry extends PantryEvent {
  final PantryEntry pantryEntry;

  const UndeletePantryEntry(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];
}

class ThrowPantryError extends PantryEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowPantryError({required this.report});

  factory ThrowPantryError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowPantryError(report: ErrorReport(error: error, trace: trace));
}
