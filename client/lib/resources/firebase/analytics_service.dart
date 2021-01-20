import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import '../../auth/auth.dart';
import '../../models/application_user.dart';

class AnalyticsService {
  FirebaseAnalytics _analytics;
  FirebaseAnalytics get analytics => isEnabled ? _analytics ??= FirebaseAnalytics() : null;

  FirebaseAnalyticsObserver _observer;
  FirebaseAnalyticsObserver get observer =>
      isEnabled ? _observer ??= FirebaseAnalyticsObserver(analytics: analytics) : null;

  // TODO: prompt users to opt in, save to user profile
  // check with analytics database:
  // https://github.com/FirebaseExtended/flutterfire/blob/1daaea78dcb61d423444fccc2238db27bf7d281e/packages/firebase_analytics/firebase_analytics/lib/firebase_analytics.dart#L50
  bool isEnabled = true;

  AnalyticsService();

  void _logEvent({@required String name, Map<String, dynamic> parameters}) {
    final condensedParameters =
        parameters == null ? null : (Map<String, dynamic>.from(parameters)..removeWhere((key, value) => value == null));
    unawaited(analytics?.logEvent(name: name, parameters: condensedParameters));
  }

  void subscribeToRoute(RouteAware routeAware, PageRoute route) => observer?.subscribe(routeAware, route);

  void unsubscribeFromRoute(RouteAware routeAware) => observer?.unsubscribe(routeAware);

  void setCurrentScreen(String screenName) => unawaited(analytics?.setCurrentScreen(screenName: screenName));

  void setUser(ApplicationUser user) => unawaited(analytics?.setUserId(user.id));

  void logEvent(String name) => _logEvent(name: name);

  void logLogin([AuthProvider authProvider]) => unawaited(analytics?.logLogin(loginMethod: authProvider?.toString()));

  void logUpdateEvent(String name, [String field]) => _logEvent(name: name, parameters: {'field': field});
}
