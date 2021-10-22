import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

@immutable
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterReady extends RegisterState {
  const RegisterReady();
}

class RegisterAwaitingEmailVerification extends RegisterState {
  final String username;

  const RegisterAwaitingEmailVerification({required this.username});
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

class RegisterError extends RegisterState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  const RegisterError({required this.message}) : report = null;

  factory RegisterError.duplicateUsername() => const RegisterError(message: 'Sorry, that email is already in use.');

  factory RegisterError.invalidUsername() => const RegisterError(message: 'Sorry, that email is invalid.');

  factory RegisterError.invalidPassword() => const RegisterError(message: 'Sorry, that password is invalid.');

  factory RegisterError.passwordTooShort() =>
      const RegisterError(message: 'Sorry, your password must be more than 10 characters.');

  factory RegisterError.passwordTooLong() =>
      const RegisterError(message: 'Sorry, your password must be less than 64 characters.');

  RegisterError.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
