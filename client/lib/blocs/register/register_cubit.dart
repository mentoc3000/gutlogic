import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final UserRepository _users;

  RegisterCubit({required UserRepository users})
      : _users = users,
        super(const RegisterInitial());

  static BlocProvider<RegisterCubit> provider({required Widget child}) {
    return BlocProvider<RegisterCubit>(create: (c) => RegisterCubit(users: c.read<UserRepository>()), child: child);
  }

  Future<void> register(Authentication auth) async {
    try {
      emit(const RegisterLoading());

      if (auth.email != null && await _users.exists(email: auth.email!)) {
        return emit(RegisterFailure.conflict());
      }

      await _users.login(authentication: auth);

      emit(RegisterSuccess(method: auth.method));
    } catch (error, trace) {
      emit(RegisterFailure.fromError(error: error, trace: trace));
    }
  }
}
