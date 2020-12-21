import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/blocs/simple_bloc_delegate.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'mock_analytics_service.dart';
import 'mock_firebase_crashlytics.dart';

AnalyticsService analyticsService;
FirebaseCrashlytics firebaseCrashlytics;

void mockBlocDelegate() {
  analyticsService = MockAnalyticsService();
  firebaseCrashlytics = MockFirebaseCrashlytics();
  BlocSupervisor.delegate = SimpleBlocDelegate(
    analyticsService: analyticsService,
    firebaseCrashlytics: firebaseCrashlytics,
  );
}
