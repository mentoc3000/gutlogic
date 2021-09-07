import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../auth/auth_provider.dart';
import '../../resources/user_repository.dart';
import 'landing_event.dart';
import 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final UserRepository repository;

  LandingBloc({
    required this.repository,
  }) : super(const LandingReady());

  factory LandingBloc.fromContext(BuildContext context) {
    return LandingBloc(repository: context.read<UserRepository>());
  }

  @override
  Stream<LandingState> mapEventToState(LandingEvent event) async* {
    if (event is LandingContinueGoogle) {
      yield* _mapContinueGoogle(event);
    }
    if (event is LandingContinueApple) {
      yield* _mapContinueApple(event);
    }
  }

  Stream<LandingState> _mapContinueGoogle(LandingContinueGoogle event) async* {
    try {
      yield const LandingLoading();
      await repository.login(provider: AuthProvider.google);
      yield const LandingSuccess();
    } on CancelledAuthenticationException {
      yield const LandingReady();
    } on DisabledUserException {
      yield LandingError.disabled();
      yield const LandingReady();
    } catch (error, trace) {
      yield LandingError.fromError(error: error, trace: trace);
      yield const LandingReady();
    }
  }

  Stream<LandingState> _mapContinueApple(LandingContinueApple event) async* {
    try {
      yield const LandingLoading();
      await repository.login(provider: AuthProvider.apple);
      yield const LandingSuccess();
    } on CancelledAuthenticationException {
      yield const LandingReady();
    } on DisabledUserException {
      yield LandingError.disabled();
      yield const LandingReady();
    } catch (error, trace) {
      yield LandingError.fromError(error: error, trace: trace);
      yield const LandingReady();
    }
  }
}
