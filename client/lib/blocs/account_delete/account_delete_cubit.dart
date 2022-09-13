import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'account_delete_state.dart';

class AccountDeleteCubit extends Cubit<AccountDeleteState> {
  final UserRepository users;

  AccountDeleteCubit({required this.users}) : super(const AccountDeleteInitial());

  static BlocProvider<AccountDeleteCubit> provider({required Widget child}) {
    return BlocProvider(create: (c) => AccountDeleteCubit(users: c.read<UserRepository>()), child: child);
  }

  Future<void> delete() async {
    try {
      emit(const AccountDeleteLoading());
      await users.delete();
      emit(const AccountDeleteSuccess());
    } on StaleAuthenticationException {
      emit(const AccountDeleteFailure.reauthenticate());
    } catch (error, trace) {
      emit(AccountDeleteFailure.fromError(error: error, trace: trace));
    }
  }
}
