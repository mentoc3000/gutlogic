import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/application_user.dart';
import '../../resources/user_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;
  late final StreamSubscription _userValueSubscription;

  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const AuthenticationUnknown()) {
    // Update the authentication state whenever the user value changes.
    _userValueSubscription = _userRepository.stream.listen(_onUserValue, onError: _onError);
  }

  factory AuthenticationBloc.fromContext(BuildContext context) {
    return AuthenticationBloc(userRepository: context.read<UserRepository>());
  }

  void _onUserValue(ApplicationUser? user) {
    add(user == null ? const AuthenticationRevoked() : const AuthenticationProvided());
  }

  void _onError(dynamic error, StackTrace trace) => add(const AuthenticationRevoked());

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AuthenticationProvided) {
      yield const Authenticated();
    } else if (event is AuthenticationRevoked) {
      yield const Unauthenticated();
    } else if (event is AuthenticationLoggedOut) {
      await _userRepository.logout();
    }
  }

  @override
  Future close() {
    _userValueSubscription.cancel();
    return super.close();
  }
}
