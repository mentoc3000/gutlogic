import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../models/application_user.dart';
import '../../resources/user_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserRepository _userRepository;

  AccountBloc({@required UserRepository userRepository})
      : assert(userRepository.authenticated),
        _userRepository = userRepository,
        super(AccountReady(user: userRepository.user));

  factory AccountBloc.fromContext(BuildContext context) {
    return AccountBloc(userRepository: context.read<UserRepository>());
  }

  ApplicationUser get _user => _userRepository.user;

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
      unawaited(_userRepository.updateMetadata(updatedUser: event.user));
      yield AccountUpdated();
      yield AccountReady(user: _user);
    } catch (error, trace) {
      yield AccountError.fromError(error: error, trace: trace);
    }
  }

  Stream<AccountState> _mapLoggedOutToState(AccountLogOut event) async* {
    try {
      await _userRepository.logout();
      yield AccountLoggedOut();
    } catch (error, trace) {
      yield AccountError.fromError(error: error, trace: trace);
    }
  }
}
