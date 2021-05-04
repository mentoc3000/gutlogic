import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import '../../util/validators.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final UserRepository userRepository;
  final Authenticator authenticator;

  ChangePasswordBloc({required this.userRepository, required this.authenticator})
      : assert(userRepository.authenticated),
        assert(userRepository.user != null),
        super(ChangePasswordEntry(user: userRepository.user!, isValid: false, isRepeated: false));

  factory ChangePasswordBloc.fromContext(BuildContext context) {
    return ChangePasswordBloc(
      userRepository: context.read<UserRepository>(),
      authenticator: Authenticator.of(context),
    );
  }

  // TODO debounce events when rebased on JPs debounce mixin

  @override
  Stream<ChangePasswordState> mapEventToState(ChangePasswordEvent event) async* {
    if (event is ChangePasswordSubmitted) {
      yield* mapSubmittedToState(event);
      return;
    }
  }

  Stream<ChangePasswordState> mapSubmittedToState(ChangePasswordSubmitted event) async* {
    if (userRepository.user!.providers.contains(AuthProvider.password)) {
      yield* _mapUpdatePasswordToState(event);
    } else {
      yield* _mapCreatePasswordToState(event);
    }
  }

  Stream<ChangePasswordState> _mapUpdatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidUpdatedPassword(user: userRepository.user!);
      return;
    }

    try {
      yield ChangePasswordLoading(user: userRepository.user!);

      // Create a new password credential using the current password.
      final auth = await authenticator.authenticate(
        provider: AuthProvider.password,
        username: userRepository.user!.username,
        password: event.currentPassword,
      );

      // Acquire a recent authentication using the current password.
      await userRepository.reauthenticate(
        credential: auth.credential,
      );

      // Replace the current password with the updated password.
      await userRepository.updatePassword(
        currentPassword: event.currentPassword,
        updatedPassword: event.updatedPassword,
      );

      yield ChangePasswordSuccess(user: userRepository.user!);
    } on WrongPasswordException {
      yield ChangePasswordError.wrongCurrentPassword(user: userRepository.user!);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: userRepository.user!, error: error, trace: trace);
    }
  }

  Stream<ChangePasswordState> _mapCreatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidCreatedPassword(user: userRepository.user!);
      return;
    }

    try {
      yield ChangePasswordLoading(user: userRepository.user!);

      // Create a new password credential using the updated password.
      final auth = await authenticator.authenticate(
        provider: AuthProvider.password,
        username: userRepository.user!.email,
        password: event.updatedPassword,
      );

      // TODO reauthenticate with federated provider

      // Link the password credential with the account.
      await userRepository.linkAuthProvider(
        provider: AuthProvider.password,
        credential: auth.credential,
      );

      yield ChangePasswordSuccess(user: userRepository.user!);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: userRepository.user!, error: error, trace: trace);
    }
  }
}
