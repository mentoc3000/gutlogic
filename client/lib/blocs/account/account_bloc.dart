import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/user_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserRepository _userRepository;

  AccountBloc({required UserRepository userRepository})
      : assert(userRepository.authenticated),
        assert(userRepository.user != null),
        _userRepository = userRepository,
        super(AccountUpdateReady(user: userRepository.user!));

  factory AccountBloc.fromContext(BuildContext context) {
    return AccountBloc(userRepository: context.read<UserRepository>());
  }

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    if (event is AccountUpdate) {
      yield* _mapUpdatedToState(event);
    } else if (event is AccountLogOut) {
      yield* _mapLoggedOutToState(event);
    }
  }

  Stream<AccountState> _mapUpdatedToState(AccountUpdate event) async* {
    try {
      final updatedUser = _userRepository.user!.rebuild((b) => b
        ..firstname = event.firstname
        ..lastname = event.lastname);

      await _userRepository.updateMetadata(updatedUser: updatedUser);

      yield AccountUpdateSuccess(user: _userRepository.user!);
    } catch (error, trace) {
      yield AccountError.fromError(error: error, trace: trace);
    }
  }

  Stream<AccountState> _mapLoggedOutToState(AccountLogOut event) async* {
    try {
      await _userRepository.logout();
    } catch (error, trace) {
      yield AccountError.fromError(error: error, trace: trace);
    }
  }
}
