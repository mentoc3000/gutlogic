import 'package:equatable/equatable.dart';

import '../../resources/firebase/analytics_service.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class AuthenticationProvided extends AuthenticationEvent {
  const AuthenticationProvided();
}

class AuthenticationRevoked extends AuthenticationEvent {
  const AuthenticationRevoked();
}

class AuthenticationLoggedOut extends AuthenticationEvent implements Tracked {
  const AuthenticationLoggedOut();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('log_out');
}
