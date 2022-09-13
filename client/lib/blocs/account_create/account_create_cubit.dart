import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'account_create_state.dart';

class AccountCreateCubit extends Cubit<AccountCreateState> {
  final UserRepository users;

  static BlocProvider<AccountCreateCubit> provider({required Widget child}) {
    return BlocProvider(create: (c) => AccountCreateCubit(users: c.read<UserRepository>()), child: child);
  }

  AccountCreateCubit({required this.users}) : super(const AccountCreateInitial());

  Future<void> create(Authentication auth) async {
    try {
      emit(const AccountCreateLoading());

      if (auth.email != null && await users.exists(email: auth.email!)) {
        return emit(AccountCreateFailure.conflict());
      }

      await users.linkAuthProvider(authentication: auth);

      emit(const AccountCreateSuccess());
    } catch (error, trace) {
      emit(AccountCreateFailure.fromError(error: error, trace: trace));
    }
  }
}
