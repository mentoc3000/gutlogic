import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'reauthenticate_state.dart';

class ReauthenticateCubit extends Cubit<ReauthenticateState> {
  final UserRepository users;

  ReauthenticateCubit({required this.users}) : super(const ReauthenticateInitial());

  static BlocProvider<ReauthenticateCubit> provider({required Widget child}) {
    return BlocProvider(create: (c) => ReauthenticateCubit(users: c.read<UserRepository>()), child: child);
  }

  Future<void> reauthenticate(Authentication auth) async {
    try {
      emit(const ReauthenticateLoading());
      await users.reauthenticate(authentication: auth);
      emit(ReauthenticateSuccess(method: auth.method));
    } catch (ex) {
      emit(const ReauthenticateFailure());
    }
  }
}
