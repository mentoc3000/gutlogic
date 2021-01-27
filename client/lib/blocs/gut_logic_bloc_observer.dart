import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../blocs/bloc_helpers.dart';
import '../resources/firebase/analytics_service.dart';
import '../util/logger.dart';

class GutLogicBlocObserver extends BlocObserver {
  final AnalyticsService analyticsService;
  final FirebaseCrashlytics firebaseCrashlytics;

  GutLogicBlocObserver({@required this.analyticsService, @required this.firebaseCrashlytics});

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object event) {
    super.onEvent(bloc, event);

    if (event is TrackedEvent) {
      event.track(analyticsService);
    }

    logger.d('Event $event');
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    logger.d(transition);

    final nextState = transition.nextState;

    if (nextState is ErrorRecorder) {
      nextState.recordError(firebaseCrashlytics);
      logger.e(nextState.report?.error);
      logger.e(nextState.report?.trace);
    }
  }

  @override
  void onError(Bloc<dynamic, dynamic> bloc, Object error, StackTrace trace) {
    super.onError(bloc, error, trace);
    logger.e(error);
    logger.e(trace);
    unawaited(firebaseCrashlytics.recordError(error, trace));
  }
}
