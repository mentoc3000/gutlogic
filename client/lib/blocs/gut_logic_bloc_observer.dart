import 'package:bloc/bloc.dart';

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

    if (event is TrackedEvent) {
      event.track(analytics);
    }

    logger.d('Event $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    logger.d(transition);

    final nextState = transition.nextState;

    if (nextState is ErrorRecorder) {
      nextState.recordError(crashlytics);
      logger.e(nextState.report?.error);
      logger.e(nextState.report?.trace);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace trace) {
    super.onError(bloc, error, trace);
    logger.e(error);
    logger.e(trace);
    crashlytics.record(error, trace);
  }
}
