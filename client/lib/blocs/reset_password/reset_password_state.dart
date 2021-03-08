import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

@immutable
abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

class ResetPasswordReady extends ResetPasswordState {
  const ResetPasswordReady();
}

class ResetPasswordSuccess extends ResetPasswordState {
  /// The email we sent the password reset link to.
  final String email;

  const ResetPasswordSuccess({this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordError extends ResetPasswordState with ErrorState, ErrorRecorder {
  @override
  final ErrorReport report;

  @override
  final String message;

  const ResetPasswordError({@required this.message}) : report = null;

  ResetPasswordError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
