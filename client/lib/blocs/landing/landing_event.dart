import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../resources/firebase/analytics_service.dart';

@immutable
abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class LandingContinueGoogle extends LandingEvent implements Tracked {
  const LandingContinueGoogle();

  @override
  void track(AnalyticsService analytics) => analytics.logLogin(AuthProvider.google);
}

class LandingContinueApple extends LandingEvent implements Tracked {
  const LandingContinueApple();

  @override
  void track(AnalyticsService analytics) => analytics.logLogin(AuthProvider.apple);
}
