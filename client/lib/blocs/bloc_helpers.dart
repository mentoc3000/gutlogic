import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../resources/firebase/crashlytics_service.dart';
import '../util/error_report.dart';

const Duration debounceDuration = Duration(milliseconds: 500);

Stream<E> debounceTransformer<E>(Stream<E> events, Stream<E> Function(E) mapper) {
  return events.debounceTime(debounceDuration).flatMap(mapper);
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

/// A base class for empty bloc states that implements Equatable.
class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
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
class UpdateFailureState extends UpdateState with ErrorState, ErrorRecorder {
  @override
  final String? message;

  @override
  final ErrorReport? report;

  const UpdateFailureState({this.message}) : report = null;

  UpdateFailureState.report({this.message, required dynamic error, required StackTrace trace})
      : report = ErrorReport(error: error, trace: trace);
}
