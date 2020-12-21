import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class AccountDeleteState extends Equatable {
  const AccountDeleteState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class AccountDeleteReady extends AccountDeleteState {
  const AccountDeleteReady();
}

class AccountDeleteReauthenticating extends AccountDeleteState {
  const AccountDeleteReauthenticating();
}

class AccountDeleteLoading extends AccountDeleteState {
  const AccountDeleteLoading();
}

class AccountDeleteDone extends AccountDeleteState {
  const AccountDeleteDone();
}

class AccountDeleteError extends AccountDeleteState with ErrorRecorder {
  @override
  final ErrorReport report;

  final String message;

  const AccountDeleteError({@required this.message}) : report = null;

  factory AccountDeleteError.password() => const AccountDeleteError(message: 'Sorry, that password is incorrect.');

  AccountDeleteError.fromError({@required dynamic error, @required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);

  @override
  List<Object> get props => [message, report];

  @override
  String toString() => 'AccountDeleteError { message: $message }';
}
