import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final UserRepository users;

  LoginCubit({required this.users}) : super(const LoginInitial());

  static BlocProvider<LoginCubit> provider({required Widget child}) {
    return BlocProvider<LoginCubit>(
      create: (c) => LoginCubit(users: c.read<UserRepository>()),
      child: child,
    );
  }

  Future<void> login(Authentication auth) async {
    try {
      emit(const LoginLoading());

      if (auth.email != null && await users.exists(email: auth.email!) == false) {
        return emit(LoginFailure.missing());
      }

      await users.login(authentication: auth);

      emit(LoginSuccess(method: auth.method));
    } on DisabledUserException {
      emit(LoginFailure.disabled());
    } catch (error, trace) {
      emit(LoginFailure.fromError(error: error, trace: trace));
    }
  }
}
