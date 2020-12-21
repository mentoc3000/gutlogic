import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../auth/auth.dart';
import '../../models/application_user.dart';
import '../../resources/user_repository.dart';
import '../../util/validators.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final UserRepository userRepository;
  final Authenticator authenticator;

  ChangePasswordBloc({@required this.userRepository, @required this.authenticator})
      : assert(userRepository != null),
        assert(authenticator != null),
        assert(userRepository.authenticated);

  factory ChangePasswordBloc.fromContext(BuildContext context) {
    return ChangePasswordBloc(
      userRepository: context.repository<UserRepository>(),
      authenticator: Authenticator.of(context),
    );
  }

  ApplicationUser get user => userRepository.user;

  @override
  ChangePasswordState get initialState => ChangePasswordEntry(user: user, isValid: false, isRepeated: false);

  // TODO debounce events when rebased on JPs debounce mixin

  @override
  Stream<ChangePasswordState> mapEventToState(ChangePasswordEvent event) async* {
    if (event is ChangePasswordUpdated) {
      yield* mapUpdatedToState(event);
      return;
    }

    if (event is ChangePasswordSubmitted) {
      yield* mapSubmittedToState(event);
      return;
    }
  }

  Stream<ChangePasswordState> mapUpdatedToState(ChangePasswordUpdated event) async* {
    try {
      final isValid = isValidPassword(event.updatedPassword);

      final isRepeated = event.updatedPassword == event.updatedRepeated &&
          event.updatedPassword.isNotEmpty &&
          event.updatedRepeated.isNotEmpty;

      yield ChangePasswordEntry(user: user, isValid: isValid, isRepeated: isRepeated);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: user, error: error, trace: trace);
    }
  }

  Stream<ChangePasswordState> mapSubmittedToState(ChangePasswordSubmitted event) async* {
    if (user.providers.contains(AuthProvider.password)) {
      yield* _mapUpdatePasswordToState(event);
    } else {
      yield* _mapCreatePasswordToState(event);
    }
  }

  Stream<ChangePasswordState> _mapUpdatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidUpdatedPassword(user: user);
      return;
    }

    try {
      yield ChangePasswordLoading(user: user);

      // Create a new password credential using the current password.
      final auth = await authenticator.authenticate(
        provider: AuthProvider.password,
        username: user.username,
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

      yield ChangePasswordSuccess(user: user);
    } on WrongPasswordException {
      yield ChangePasswordError.wrongCurrentPassword(user: user);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: user, error: error, trace: trace);
    }
  }

  Stream<ChangePasswordState> _mapCreatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidCreatedPassword(user: user);
      return;
    }

    try {
      yield ChangePasswordLoading(user: user);

      // Create a new password credential using the updated password.
      final auth = await authenticator.authenticate(
        provider: AuthProvider.password,
        username: user.email,
        password: event.updatedPassword,
      );

      // TODO reauthenticate with federated provider

      // Link the password credential with the account.
      await userRepository.linkAuthProvider(
        provider: AuthProvider.password,
        credential: auth.credential,
      );

      yield ChangePasswordSuccess(user: user);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: user, error: error, trace: trace);
    }
  }
}
