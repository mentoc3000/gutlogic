import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/blocs/gut_logic_bloc_observer.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';

import 'mock_analytics_service.dart';
import 'mock_firebase_crashlytics.dart';

AnalyticsService analyticsService;
FirebaseCrashlytics firebaseCrashlytics;

void mockBlocDelegate() {
  analyticsService = MockAnalyticsService();
  firebaseCrashlytics = MockFirebaseCrashlytics();
  Bloc.observer = GutLogicBlocObserver(
    analyticsService: analyticsService,
    firebaseCrashlytics: firebaseCrashlytics,
  );
}
