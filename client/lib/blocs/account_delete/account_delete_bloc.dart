import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'account_delete_event.dart';
import 'account_delete_state.dart';

class AccountDeleteBloc extends Bloc<AccountDeleteEvent, AccountDeleteState> {
  final UserRepository repository;

  AccountDeleteBloc({required this.repository}) : super(const AccountDeleteReady());

  @override
  Stream<AccountDeleteState> mapEventToState(AccountDeleteEvent event) async* {
    if (event is AccountDeletePasswordConfirm) {
      yield* _mapPasswordConfirmToState(event);
    }

    if (event is AccountDeleteFederatedConfirm) {
      yield* _mapFederatedConfirmToState(event);
    }
  }

  Stream<AccountDeleteState> _mapPasswordConfirmToState(AccountDeletePasswordConfirm event) async* {
    try {
      yield const AccountDeleteLoading();
      await repository.delete();
      yield const AccountDeleteDone();
    } on WrongPasswordException {
      yield AccountDeleteError.password();
      yield const AccountDeleteReady();
    } on InvalidPasswordException {
      yield AccountDeleteError.password();
      yield const AccountDeleteReady();
    } catch (error, trace) {
      yield AccountDeleteError.fromError(error: error, trace: trace);
      yield const AccountDeleteReady();
    }
  }

  Stream<AccountDeleteState> _mapFederatedConfirmToState(AccountDeleteFederatedConfirm event) async* {
    try {
      yield const AccountDeleteLoading();
      await repository.delete();
      yield const AccountDeleteDone();
    } catch (error, trace) {
      yield AccountDeleteError.fromError(error: error, trace: trace);
      yield const AccountDeleteReady();
    }
  }
}
