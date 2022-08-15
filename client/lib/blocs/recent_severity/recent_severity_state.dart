import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/severity.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class RecentSeverityState extends Equatable {
  const RecentSeverityState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class RecentSeverityLoading extends RecentSeverityState {
  const RecentSeverityLoading();
}

class RecentSeverityLoaded extends RecentSeverityState {
  final BuiltMap<DateTime, Severity?> recentSeverities;

  const RecentSeverityLoaded(this.recentSeverities);

  @override
  List<Object?> get props => [recentSeverities];
}

class RecentSeverityError extends RecentSeverityState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  RecentSeverityError({required this.message}) : report = null;

  RecentSeverityError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? firestoreExceptionString(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  factory RecentSeverityError.fromReport(ErrorReport report) =>
      RecentSeverityError.fromError(error: report.error, trace: report.trace);
}
