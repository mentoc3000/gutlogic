import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/symptom_type.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class SymptomTypeCountState extends Equatable {
  const SymptomTypeCountState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class SymptomTypeCountLoading extends SymptomTypeCountState {
  const SymptomTypeCountLoading();
}

class SymptomTypeCountLoaded extends SymptomTypeCountState {
  final BuiltMap<SymptomType, int> symptomTypeCount;

  const SymptomTypeCountLoaded(this.symptomTypeCount);

  @override
  List<Object?> get props => [symptomTypeCount];
}

class SymptomTypeCountError extends SymptomTypeCountState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  SymptomTypeCountError({required this.message}) : report = null;

  SymptomTypeCountError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory SymptomTypeCountError.fromReport(ErrorReport report) =>
      SymptomTypeCountError.fromError(error: report.error, trace: report.trace);
}
