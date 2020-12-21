import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

@immutable
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginReady extends LoginState {
  const LoginReady();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginError extends LoginState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  const LoginError({@required this.message}) : report = null;

  factory LoginError.rejected() => const LoginError(message: 'Sorry, either your email or password is incorrect.');
  factory LoginError.disabled() => const LoginError(message: 'Sorry, that account has been disabled.');

  LoginError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'LoginError { message: $message }';
}
