import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import '../../util/validators.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  final Authenticator authenticator;

  RegisterBloc({required this.userRepository, required this.authenticator}) : super(const RegisterReady());

  factory RegisterBloc.fromContext(BuildContext context) => RegisterBloc(
        userRepository: context.read<UserRepository>(),
        authenticator: context.read<Authenticator>(),
      );

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterSubmitted) {
      yield* _mapSubmittedToState(event);
    }
  }

  Stream<RegisterState> _mapSubmittedToState(RegisterSubmitted event) async* {
    assert(state is RegisterReady);

    try {
      yield const RegisterLoading();

      if (isValidUsername(event.username) == false) {
        yield RegisterError.invalidUsername();
        yield const RegisterReady();
        return;
      }

      if (isPasswordTooShort(event.password)) {
        yield RegisterError.passwordTooShort();
        yield const RegisterReady();
        return;
      }

      if (isPasswordTooLong(event.password)) {
        yield RegisterError.passwordTooLong();
        yield const RegisterReady();
        return;
      }

      await userRepository.register(
        username: event.username,
        password: event.password,
      );

      await userRepository.sendEmailVerification();

      yield const RegisterSuccess();
    } on DuplicateUsernameException {
      yield RegisterError.duplicateUsername();
      yield const RegisterReady();
    } on InvalidUsernameException {
      yield RegisterError.invalidUsername();
      yield const RegisterReady();
    } on InvalidPasswordException {
      yield RegisterError.invalidPassword();
      yield const RegisterReady();
    } catch (error, trace) {
      yield RegisterError.fromError(error: error, trace: trace);
      yield const RegisterReady();
    }
  }
}
