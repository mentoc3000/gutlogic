import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../auth/auth_provider.dart';
import '../../resources/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository repository;

  LoginBloc({required this.repository}) : super(const LoginReady());

  factory LoginBloc.fromContext(BuildContext context) {
    return LoginBloc(repository: context.read<UserRepository>());
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginSubmitted) {
      yield* _mapSubmittedToState(event);
    }
  }

  Stream<LoginState> _mapSubmittedToState(LoginSubmitted event) async* {
    if (event.username.isEmpty || event.password.isEmpty) {
      yield LoginError.rejected();
      yield const LoginReady();
      return;
    }

    try {
      yield const LoginLoading();

      await repository.login(
        provider: AuthProvider.password,
        username: event.username,
        password: event.password,
      );

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
