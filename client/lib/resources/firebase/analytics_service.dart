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

  static Map<String, String> _removeNulls(Map<String, String> parameters) =>
      Map.from(parameters)..removeWhere((key, value) => value == null);

  void subscribeToRoute(RouteAware routeAware, PageRoute route) => observer?.subscribe(routeAware, route);

  void unsubscribeFromRoute(RouteAware routeAware) => observer?.unsubscribe(routeAware);

  void setCurrentScreen(String screenName) => unawaited(analytics?.setCurrentScreen(screenName: screenName));

  void setUser(ApplicationUser user) => unawaited(analytics?.setUserId(user.id));

  void logRegister({AuthProvider authProvider}) => unawaited(analytics?.logEvent(
        name: 'register',
        parameters: _removeNulls({'auth_provider': authProvider?.toString()}),
      ));

  void logLogin({AuthProvider authProvider}) => unawaited(analytics?.logLogin(loginMethod: authProvider?.toString()));

  void logPasswordChange() => unawaited(analytics?.logEvent(name: 'password_change'));

  void logUpdateProfile() => unawaited(analytics?.logEvent(name: 'update_profile'));

  void logLogOut() => unawaited(analytics?.logEvent(name: 'log_out'));

  void logCreateMealEntry() => unawaited(analytics?.logEvent(name: 'create_meal_entry'));

  void logCreateBowelMovementEntry() => unawaited(analytics?.logEvent(name: 'create_bowel_movement_entry'));

  void logCreateSymptomEntry() => unawaited(analytics?.logEvent(name: 'create_symptom_entry'));

  void logCreateMealElement() => unawaited(analytics?.logEvent(name: 'create_mealElement'));

  void logCreateCustomFood() => unawaited(analytics?.logEvent(name: 'create_custom_food'));

  void logUpdateMealEntry({String field}) => unawaited(analytics?.logEvent(
        name: 'update_meal_entry',
        parameters: _removeNulls({'field': field}),
      ));

  void logUpdateBowelMovementEntry({String field}) => unawaited(analytics?.logEvent(
        name: 'update_bowel_movement_entry',
        parameters: _removeNulls({'field': field}),
      ));

  void logUpdateSymptomEntry({String field}) => unawaited(analytics?.logEvent(
        name: 'update_symptom_entry',
        parameters: _removeNulls({'field': field}),
      ));

  void logUpdateMealElement({String field}) => unawaited(analytics?.logEvent(
        name: 'update_mealElement',
        parameters: _removeNulls({'field': field}),
      ));

  void logDeleteMealEntry({String action}) => unawaited(analytics?.logEvent(
        name: 'delete_meal_entry',
        parameters: _removeNulls({'action': action}),
      ));

  void logDeleteBowelMovementEntry({String action}) => unawaited(analytics?.logEvent(
        name: 'delete_bowel_movement_entry',
        parameters: _removeNulls({'action': action}),
      ));

  void logDeleteSymptomEntry({String action}) => unawaited(analytics?.logEvent(
        name: 'delete_symptom_entry',
        parameters: _removeNulls({'action': action}),
      ));

  void logDeleteMealElement({String action}) => unawaited(analytics?.logEvent(
        name: 'delete_mealElement',
        parameters: _removeNulls({'action': action}),
      ));

  void logDeleteCustomFood() => unawaited(analytics?.logEvent(name: 'delete_custom_food'));

  void logFoodSearch({String searchTerm}) => unawaited(analytics?.logEvent(
        name: 'food_search',
        parameters: _removeNulls({'search_term': searchTerm}),
      ));

  void logSymptomTypeSearch({String searchTerm}) => unawaited(analytics?.logEvent(
        name: 'symptom_type_search',
        parameters: _removeNulls({'search_term': searchTerm}),
      ));
}
