import '../../util/error_report.dart';
import '../bloc_helpers.dart';

class AccountCreateState extends BaseState {
  const AccountCreateState();
}

class AccountCreateInitial extends AccountCreateState {
  const AccountCreateInitial();
}

class AccountCreateLoading extends AccountCreateState {
  const AccountCreateLoading();
}

class AccountCreateSuccess extends AccountCreateState {
  const AccountCreateSuccess();
}

class AccountCreateFailure extends AccountCreateState with ErrorState, ErrorRecorder {
  @override
  final String? message;

  @override
  final ErrorReport? report;

  static AccountCreateFailure conflict() {
    return const AccountCreateFailure(message: 'Sorry, an account with that email already exists.');
  }

  const AccountCreateFailure({required this.message}) : report = null;

  AccountCreateFailure.fromError({required dynamic error, required StackTrace trace})
      : message = null,
        report = ErrorReport(error: error, trace: trace);
}
