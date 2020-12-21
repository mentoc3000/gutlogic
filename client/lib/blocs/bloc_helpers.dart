import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../resources/firebase/analytics_service.dart';
import '../util/error_report.dart';
import '../util/logger.dart';

mixin DebouncedEvent {}

abstract class TrackedEvent {
  void track(AnalyticsService analyticsService) {
    logger.w('Unimplemented method $runtimeType.track().');
  }
}

const Duration debounceDuration = Duration(milliseconds: 500);

Stream<E> debounceAll<E>(Stream<E> events) {
  return events.debounceTime(debounceDuration);
}

Stream<E> debounceAllByType<E>(Stream<E> events) {
  return events.groupBy((event) => event.runtimeType).flatMap((stream) => stream.debounceTime(debounceDuration));
}

Stream<E> debounceAllDebounced<E>(Stream<E> events) {
  assert(events.isBroadcast);
  final nonDebounceStream = events.where((event) => event is! DebouncedEvent);
  final debouncedStream = events.where((event) => event is DebouncedEvent).debounceTime(debounceDuration);
  return MergeStream([nonDebounceStream, debouncedStream]);
}

Stream<E> debounceDebouncedByType<E>(Stream<E> events) {
  assert(events.isBroadcast);
  final nonDebounceStream = events.where((event) => event is! DebouncedEvent);
  final debounceStream = events.where((event) => event is DebouncedEvent);
  final debouncedStreams =
      debounceStream.groupBy((event) => event.runtimeType).flatMap((stream) => stream.debounceTime(debounceDuration));
  return MergeStream([nonDebounceStream, debouncedStreams]);
}

mixin StreamSubscriber<E, S> on Bloc<E, S> {
  StreamSubscription streamSubscription;

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}

mixin ErrorRecorder {
  ErrorReport get report;

  void recordError(FirebaseCrashlytics firebaseCrashlytics) {
    if (report != null) firebaseCrashlytics.recordError(report.error, report.trace);
  }
}
