import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent implements Tracked {
  final String username;
  final String password;

  const LoginSubmitted({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];

  @override
  void track(AnalyticsService analytics) => analytics.logLogin(AuthProvider.password);
}
