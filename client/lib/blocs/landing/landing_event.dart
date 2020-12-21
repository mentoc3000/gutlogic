import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

@immutable
abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LandingContinueGoogle extends LandingEvent implements TrackedEvent {
  const LandingContinueGoogle();

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logLogin(authProvider: AuthProvider.google);
}

class LandingContinueApple extends LandingEvent implements TrackedEvent {
  const LandingContinueApple();

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logLogin(authProvider: AuthProvider.apple);
}
