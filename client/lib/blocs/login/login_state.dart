import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class LoginState extends BaseState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState implements Tracked {
  final AuthMethod method;

  const LoginSuccess({required this.method});

  @override
  void track(AnalyticsService analytics) => analytics.logLogin(method);
}

class LoginFailure extends LoginState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  const LoginFailure({required this.message}) : report = null;

  static LoginFailure disabled() {
    const message = 'Sorry, that account has been disabled. Please contact info@gutlogic.co for details.';
    return const LoginFailure(message: message);
  }

  static LoginFailure missing() {
    const message = 'Sorry, that account does not exist. Did you mean to sign up?';
    return const LoginFailure(message: message);
  }

  LoginFailure.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
