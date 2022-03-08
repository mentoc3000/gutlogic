import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class AccountDeleteState extends BaseState {
  const AccountDeleteState();
}

class AccountDeleteInitial extends AccountDeleteState {
  const AccountDeleteInitial();
}

class AccountDeleteLoading extends AccountDeleteState {
  const AccountDeleteLoading();
}

class AccountDeleteSuccess extends AccountDeleteState {
  const AccountDeleteSuccess();
}

class AccountDeleteFailure extends AccountDeleteState with ErrorState, ErrorRecorder {
  @override
  final String? message;

  @override
  final ErrorReport? report;

  const AccountDeleteFailure.reauthenticate()
      : message = 'The authentication is stale.',
        report = null;

  const AccountDeleteFailure({required this.message}) : report = null;

  AccountDeleteFailure.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
