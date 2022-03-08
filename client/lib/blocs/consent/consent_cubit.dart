import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/user_repository.dart';
import 'consent_state.dart';

class ConsentCubit extends Cubit<ConsentState> {
  final UserRepository _users;

  static BlocProvider<ConsentCubit> provider({required Widget child}) {
    return BlocProvider<ConsentCubit>(create: (c) => ConsentCubit(users: c.read<UserRepository>()), child: child);
  }

  ConsentCubit({required UserRepository users})
      : _users = users,
        super(const ConsentInitial());

  void consent() async {
    try {
      assert(_users.user != null);
      emit(const ConsentLoading());
      await _users.consent(_users.user!);
      emit(const ConsentSuccess());
    } catch (ex) {
      emit(const ConsentInitial());
    }
  }
}
