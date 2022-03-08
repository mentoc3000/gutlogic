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

  // NAVIGATION

  void subscribeToRoute(RouteAware routeAware, PageRoute route) => _observer?.subscribe(routeAware, route);

  void unsubscribeFromRoute(RouteAware routeAware) => _observer?.unsubscribe(routeAware);

  void setCurrentScreen(String screenName) => _analytics?.setCurrentScreen(screenName: screenName);

  // AUTHENTICATION and USER

  void setUser(ApplicationUser user) => _analytics?.setUserId(user.id);

  void logEvent(String name) => _analytics?.logEvent(name: name);

  void logLogin(AuthMethod method) => _analytics?.logLogin(loginMethod: method.toString());

  void logRegistration(AuthMethod method) {
    switch (method) {
      case AuthMethod.anonymous:
        _analytics?.logEvent(name: 'register_with_anonymous');
        break;
      case AuthMethod.apple:
        _analytics?.logEvent(name: 'register_with_apple');
        break;
      case AuthMethod.email:
        _analytics?.logEvent(name: 'register_with_email');
        break;
      case AuthMethod.google:
        _analytics?.logEvent(name: 'register_with_google');
        break;
    }
    // TODO replace above case statement with enum extension in Flutter 2.15
    // _analytics?.logEvent(name: 'register_with_${method.name}');
  }

  void logUpdateEvent(String name, [String? field]) {
    _analytics?.logEvent(name: name, parameters: field == null ? null : {field: field});
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

/// Interface for objects that can track something via the analytics service.
abstract class Tracked {
  void track(AnalyticsService analytics);
}
