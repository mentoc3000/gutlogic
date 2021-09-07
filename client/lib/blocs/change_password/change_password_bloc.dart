import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import '../../util/validators.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final UserRepository repository;

  ChangePasswordBloc({required this.repository})
      : assert(repository.authenticated),
        assert(repository.user != null),
        super(ChangePasswordEntry(user: repository.user!, isValid: false, isRepeated: false));

  factory ChangePasswordBloc.fromContext(BuildContext context) {
    return ChangePasswordBloc(repository: context.read<UserRepository>());
  }

  @override
  Stream<ChangePasswordState> mapEventToState(ChangePasswordEvent event) async* {
    if (event is ChangePasswordSubmitted) {
      yield* mapSubmittedToState(event);
      return;
    }
  }

  Stream<ChangePasswordState> mapSubmittedToState(ChangePasswordSubmitted event) async* {
    if (repository.user!.providers.contains(AuthProvider.password)) {
      yield* _mapUpdatePasswordToState(event);
    } else {
      yield* _mapCreatePasswordToState(event);
    }
  }

  Stream<ChangePasswordState> _mapUpdatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidUpdatedPassword(user: repository.user!);
      return;
    }

    try {
      yield ChangePasswordLoading(user: repository.user!);

      // Replace the current password with the updated password.
      await repository.updatePassword(
        currentPassword: event.currentPassword,
        updatedPassword: event.updatedPassword,
      );

      yield ChangePasswordSuccess(user: repository.user!);
    } on WrongPasswordException {
      yield ChangePasswordError.wrongCurrentPassword(user: repository.user!);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: repository.user!, error: error, trace: trace);
    }
  }

  Stream<ChangePasswordState> _mapCreatePasswordToState(ChangePasswordSubmitted event) async* {
    if (isValidPassword(event.updatedPassword) == false) {
      yield ChangePasswordError.invalidCreatedPassword(user: repository.user!);
      return;
    }

    try {
      yield ChangePasswordLoading(user: repository.user!);

      // Link the password credential with the account.
      await repository.linkAuthProvider(
        provider: AuthProvider.password,
        password: event.updatedPassword,
      );

      yield ChangePasswordSuccess(user: repository.user!);
    } catch (error, trace) {
      yield ChangePasswordError.fromError(user: repository.user!, error: error, trace: trace);
    }
  }
}
