import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../../util/exception_messages.dart';
import '../bloc_helpers.dart';

abstract class RegisterState extends BaseState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState implements Tracked {
  final AuthMethod method;

  const RegisterSuccess({required this.method});

  @override
  void track(AnalyticsService analytics) => analytics.logRegistration(method);

  @override
  List<Object?> get props => [method];
}

class RegisterFailure extends RegisterState with ErrorState, ErrorRecorder {
  @override
  final String message;

  @override
  final ErrorReport? report;

  const RegisterFailure({required this.message}) : report = null;

  static RegisterFailure conflict() {
    return const RegisterFailure(message: 'Sorry, an account with that email already exists. Did you mean to sign in?');
  }

  RegisterFailure.fromError({required dynamic error, required StackTrace trace})
      : message = connectionExceptionMessage(error) ?? defaultExceptionString,
        report = ErrorReport(error: error, trace: trace);
}
