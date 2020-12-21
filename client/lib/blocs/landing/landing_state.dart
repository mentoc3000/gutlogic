import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

@immutable
abstract class LandingState extends Equatable {
  const LandingState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LandingReady extends LandingState {
  const LandingReady();
}

class LandingLoading extends LandingState {
  const LandingLoading();
}

class LandingSuccess extends LandingState {
  const LandingSuccess();
}

class LandingError extends LandingState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  const LandingError({@required this.message}) : report = null;

  factory LandingError.disabled() => const LandingError(message: 'Sorry, that account has been disabled.');

  LandingError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'LandingError { message: $message }';
}
