import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

@immutable
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class RegisterSubmitted extends RegisterEvent implements TrackedEvent {
  final String username;
  final String password;

  const RegisterSubmitted({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logRegister(authProvider: AuthProvider.password);
}

class RegisterResendEmailVerification extends RegisterEvent {
  const RegisterResendEmailVerification();
}
