import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class PantryEntryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PantryEntryLoading extends PantryEntryState {}

class PantryEntryLoaded extends PantryEntryState {
  final PantryEntry pantryEntry;
  final Food? food;
  final BuiltSet<String> excludedIrritants;

  PantryEntryLoaded({required this.pantryEntry, required this.food, required this.excludedIrritants});

  @override
  List<Object?> get props => [pantryEntry, food, excludedIrritants];
}

class PantryEntryError extends PantryEntryState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  PantryEntryError({required this.message}) : report = null;

  PantryEntryError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory PantryEntryError.fromReport(ErrorReport report) {
    return PantryEntryError.fromError(error: report.error, trace: report.trace);
  }
}
