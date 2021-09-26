import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../resources/firebase/analytics_service.dart';

@immutable
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class RegisterSubmitted extends RegisterEvent implements Tracked {
  final String username;
  final String password;

  const RegisterSubmitted({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('register_with_email');
}

class RegisterResendEmailVerification extends RegisterEvent {
  const RegisterResendEmailVerification();
}
