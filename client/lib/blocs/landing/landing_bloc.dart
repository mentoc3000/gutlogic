import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../auth/auth_provider.dart';
import '../../resources/user_repository.dart';
import 'landing_event.dart';
import 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final UserRepository userRepository;
  final Authenticator authenticator;

  LandingBloc({
    @required this.userRepository,
    @required this.authenticator,
  });

  factory LandingBloc.fromContext(BuildContext context) {
    return LandingBloc(
      userRepository: context.repository<UserRepository>(),
      authenticator: Authenticator.of(context),
    );
  }

  @override
  LandingState get initialState => const LandingReady();

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

      final auth = await authenticator.authenticate(
        provider: AuthProvider.google,
      );

      await userRepository.login(credential: auth.credential);

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

      final auth = await authenticator.authenticate(
        provider: AuthProvider.apple,
      );

      await userRepository.login(credential: auth.credential);

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
