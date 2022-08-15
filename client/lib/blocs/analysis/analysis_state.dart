import 'package:equatable/equatable.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class AnalysisLoading extends AnalysisState {
  const AnalysisLoading();
}

class AnalysisLoaded extends AnalysisState {
  const AnalysisLoaded();

  @override
  List<Object?> get props => [];
}

class AnalysisError extends AnalysisState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  AnalysisError({required this.message}) : report = null;

  AnalysisError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory AnalysisError.fromReport(ErrorReport report) =>
      AnalysisError.fromError(error: report.error, trace: report.trace);
}
