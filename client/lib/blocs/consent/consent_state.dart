import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

@immutable
abstract class ConsentState extends Equatable {
  const ConsentState();

  @override
  List<Object?> get props => [];
}

class ConsentLoading extends ConsentState {
  const ConsentLoading();
}

class ConsentReady extends ConsentState {
  const ConsentReady();
}

class ConsentDone extends ConsentState {
  const ConsentDone();
}

class ConsentError extends ConsentState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  const ConsentError({required this.message}) : report = null;

  ConsentError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
