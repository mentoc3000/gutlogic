import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../auth/auth_provider.dart';
import '../../resources/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final Authenticator authenticator;

  LoginBloc({@required this.userRepository, @required this.authenticator}) : super(const LoginReady());

  factory LoginBloc.fromContext(BuildContext context) => LoginBloc(
        userRepository: context.repository<UserRepository>(),
        authenticator: Authenticator.of(context),
      );

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginSubmitted) {
      yield* _mapSubmittedToState(event);
    }
  }

  Stream<LoginState> _mapSubmittedToState(LoginSubmitted event) async* {
    try {
      yield const LoginLoading();

      final auth = await authenticator.authenticate(
        provider: AuthProvider.password,
        username: event.username,
        password: event.password,
      );

      await userRepository.login(credential: auth.credential);

      yield const LoginSuccess();
    } on WrongPasswordException {
      yield LoginError.rejected();
      yield const LoginReady();
    } on MissingUserException {
      yield LoginError.rejected();
      yield const LoginReady();
    } on DisabledUserException {
      yield LoginError.disabled();
      yield const LoginReady();
    } catch (error, trace) {
      yield LoginError.fromError(error: error, trace: trace);
      yield const LoginReady();
    }
  }
}
