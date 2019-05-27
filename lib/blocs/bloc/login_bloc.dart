import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
// import 'package:user_repository/user_repository.dart';

import 'login_event.dart';
import 'login_state.dart';
import 'authentication_bloc.dart';
import '../../resources/user_repository.dart';
import 'authentication_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final hasAccess = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        if (hasAccess) {
          authenticationBloc.dispatch(LoggingIn());
        }
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}