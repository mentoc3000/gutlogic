import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/pantry/pantry_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_state.dart';

abstract class PantryState extends Equatable {
  const PantryState();

  @override
  List<Object?> get props => [];
}

class PantryLoading extends PantryState with SearchableLoading {}

class PantryLoaded extends PantryState with SearchableLoaded {
  @override
  final BuiltList<PantryEntry> items;

  PantryLoaded(this.items);
}

class PantryEntryDeleted extends PantryState {
  final PantryEntry pantryEntry;

  PantryEntryDeleted(this.pantryEntry);

  @override
  List<Object?> get props => [pantryEntry];
}

class PantryError extends PantryState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  PantryError({required this.message}) : report = null;

  PantryError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory PantryError.fromReport(ErrorReport report) => PantryError.fromError(error: report.error, trace: report.trace);
}
