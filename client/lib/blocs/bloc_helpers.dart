import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../resources/firebase/crashlytics_service.dart';
import '../util/error_report.dart';

mixin DebouncedEvent {}

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

mixin StreamSubscriber<StreamData, State> on BlocBase<State> {
  StreamSubscription<StreamData>? streamSubscription;

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}

mixin ErrorState on Equatable {
  String? get message;

  @override
  List<Object?> get props => [message];
}

mixin ErrorRecorder on ErrorState {
  ErrorReport? get report;

  @override
  List<Object?> get props => [message, report];

  void recordError(CrashlyticsService crashlytics) {
    if (report == null) return;
    final error = report!.error;
    final trace = report!.trace;
    crashlytics.record(error, trace);
  }
}

mixin ErrorEvent on Equatable {
  ErrorReport get report;

  @override
  List<Object?> get props => [report];
}

/// A base class for simple data update states.
abstract class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

/// Emitted before the data has been updated.
class UpdateInitialState extends UpdateState {
  const UpdateInitialState();
}

/// Emitted while the data update is being performed.
class UpdateSavingState extends UpdateState {
  const UpdateSavingState();
}

/// Emitted after the data update was accepted.
class UpdateSuccessState extends UpdateState {
  const UpdateSuccessState();
}

/// Emitted after the data update was rejected.
class UpdateFailureState extends UpdateState with ErrorState {
  @override
  final String? message;

  const UpdateFailureState({this.message});
}
