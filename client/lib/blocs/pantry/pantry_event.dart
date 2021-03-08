import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';

import '../../models/pantry_entry.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

export '../searchable/searchable_event.dart';

abstract class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class StreamAllPantry extends PantryEvent with StreamAll {
  const StreamAllPantry();
}

class LoadPantry extends PantryEvent with LoadSearchables {
  @override
  final BuiltList<PantryEntry> items;

  const LoadPantry({@required this.items});
}

class StreamPantryQuery extends PantryEvent with StreamQuery implements TrackedEvent {
  @override
  final String query;

  const StreamPantryQuery(this.query);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('pantry_search');
}

class DeletePantryEntry extends PantryEvent implements TrackedEvent {
  final PantryEntry pantryEntry;

  const DeletePantryEntry(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];

  @override
  String toString() => 'Delete { id: ${pantryEntry.id} }';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_pantry_entry');
}

class UndeletePantryEntry extends PantryEvent {
  final PantryEntry pantryEntry;

  const UndeletePantryEntry(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];
}

class ThrowPantryError extends PantryEvent with ErrorEvent {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowPantryError({this.error, this.trace});
}
