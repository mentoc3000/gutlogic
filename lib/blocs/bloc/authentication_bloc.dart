import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import '../../resources/user_repository.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasAccess = await userRepository.hasAccess();

      if (hasAccess) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggingIn) {
      yield AuthenticationLoading();
      // await userRepository.persistToken(event.token);
      final bool hasAccess = await userRepository.hasAccess();
      print(hasAccess);
      if (hasAccess) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }

    }

    if (event is LoggingOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}