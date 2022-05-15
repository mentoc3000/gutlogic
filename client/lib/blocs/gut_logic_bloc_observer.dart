import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bloc_helpers.dart';
import '../resources/firebase/analytics_service.dart';
import '../resources/firebase/crashlytics_service.dart';
import '../util/logger.dart';

class GutLogicBlocObserver extends BlocObserver {
  final AnalyticsService analytics;
  final CrashlyticsService crashlytics;

  GutLogicBlocObserver({required this.analytics, required this.crashlytics});

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    if (event is Tracked) {
      event.track(analytics);
    }

    logger.d('Event $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    logger.d(transition);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    final nextState = change.nextState;

    // Bloc and cubit states both invoke onChange, but only bloc states invoke onTransition. We handle analytics and
    // crashlytics integration in onChange so that we handle both bloc and cubit state changes.

    if (nextState is Tracked) {
      nextState.track(analytics);
    }

    if (nextState is ErrorRecorder) {
      nextState.recordError(crashlytics);
      logger.e(nextState.report?.error);
      logger.e(nextState.report?.trace);
    }

    logger.d(change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace trace) {
    super.onError(bloc, error, trace);
    logger.e(error);
    logger.e(trace);
    crashlytics.record(error, trace);
  }
}
