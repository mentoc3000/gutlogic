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
      await userRepository.init();
      final bool hasAccess = await userRepository.hasAccess();

      if (hasAccess) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      // await userRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.signOut();
      yield AuthenticationUnauthenticated();
    }

    if (event is NewUser) {
      yield AuthenticationLoading();
      // await userRepository.deleteToken();
      yield AuthenticationNewUser();
    }

    if (event is Reauthenticate) {
      yield AuthenticationLoading();
      // await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }

    if (event is Confirm) {
      yield AuthenticationLoading();
      // await userRepository.persistToken(event.token);
      yield AuthenticationUnconfirmed(username: event.username);
    }

    if (event is Confirmed) {
      yield AuthenticationLoading();
      // await userRepository.persistToken(event.token);
      yield AuthenticationUnauthenticated();
    }
  }
}