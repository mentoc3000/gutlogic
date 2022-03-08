import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class ConsentState extends BaseState {
  const ConsentState();
}

class ConsentLoading extends ConsentState {
  const ConsentLoading();
}

class ConsentInitial extends ConsentState {
  const ConsentInitial();
}

class ConsentSuccess extends ConsentState implements Tracked {
  const ConsentSuccess();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('consented');
}
