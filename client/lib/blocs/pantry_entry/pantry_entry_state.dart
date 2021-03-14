import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class PantryEntryState extends Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class PantryEntryLoading extends PantryEntryState {}

class PantryEntryLoaded extends PantryEntryState {
  final PantryEntry pantryEntry;

  PantryEntryLoaded(this.pantryEntry);

  @override
  List<Object> get props => [pantryEntry];

  @override
  String toString() => 'PantryEntryLoaded { pantryEntry: ${pantryEntry.id} }';
}

class PantryEntryError extends PantryEntryState with ErrorState, ErrorRecorder {
  @override
  final ErrorReport report;

  @override
  final String message;

  PantryEntryError({@required this.message}) : report = null;

  PantryEntryError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
