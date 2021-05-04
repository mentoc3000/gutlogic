import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/widgets.dart';

import '../../auth/auth.dart';
import '../../models/application_user.dart';

class AnalyticsService {
  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  AnalyticsService({bool enabled = true}) {
    if (enabled) {
      _analytics = FirebaseAnalytics();
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    } else {
      _analytics = null;
      _observer = null;
    }
  }

  /// Create a new analytics observer.
  AnalyticsObserver observer() {
    return AnalyticsObserver(_observer);
  }

  /// Track an analytics event, with optional [parameters].
  void _track({required String name, Map<String, Object>? parameters}) {
    _analytics?.logEvent(name: name, parameters: parameters);
  }

  // NAVIGATION

  void subscribeToRoute(RouteAware routeAware, PageRoute route) => _observer?.subscribe(routeAware, route);

  void unsubscribeFromRoute(RouteAware routeAware) => _observer?.unsubscribe(routeAware);

  void setCurrentScreen(String screenName) => _analytics?.setCurrentScreen(screenName: screenName);

  // AUTHENTICATION and USER

  void setUser(ApplicationUser user) => _analytics?.setUserId(user.id);

  void logEvent(String name) => _track(name: name);

  void logLogin(AuthProvider provider) => _analytics?.logLogin(loginMethod: provider.toString());

  void logUpdateEvent(String name, [String? field]) {
    _track(name: name, parameters: field == null ? null : {field: field});
  }
}

class AnalyticsObserver extends RouteObserver<PageRoute<dynamic>> {
  final FirebaseAnalyticsObserver? _firebaseAnalyticsObserver;

  AnalyticsObserver(FirebaseAnalyticsObserver? observer) : _firebaseAnalyticsObserver = observer;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _firebaseAnalyticsObserver?.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _firebaseAnalyticsObserver?.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _firebaseAnalyticsObserver?.didPop(route, previousRoute);
  }
}
