import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/user_repository.dart';
import 'verify_email_event.dart';
import 'verify_email_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final UserRepository _userRepository;

  StreamSubscription _userValueSubscription;
  StreamSubscription _userRefreshSubscription;

  VerifyEmailBloc({@required UserRepository userRepository}) : _userRepository = userRepository {
    assert(userRepository.authenticated);

    // Refresh the bloc state every two seconds, because verifying the email does not emit a new user value.
    _userRefreshSubscription = Stream.periodic(const Duration(seconds: 2)).listen(_onUserRefreshTimeout);
  }

  factory VerifyEmailBloc.fromContext(BuildContext context) {
    return VerifyEmailBloc(userRepository: context.repository<UserRepository>());
  }

  void _onUserRefreshTimeout(_) {
    add(VerifyEmailAutoRefreshed());
  }

  @override
  Future close() {
    _userRefreshSubscription?.cancel();
    _userValueSubscription?.cancel();
    return super.close();
  }

  @override
  VerifyEmailState get initialState => VerifyEmailValue(verified: _userRepository.user.verified);

  @override
  Stream<VerifyEmailState> mapEventToState(VerifyEmailEvent event) async* {
    yield VerifyEmailLoading();

    if (event is VerifyEmailExitRequested) {
      yield VerifyEmailExiting();
      await _userRepository.logout();
    } else {
      final isEmailVerified = await _userRepository.refreshEmailVerification();

      if (event is VerifyEmailUserRefreshed && isEmailVerified == false) {
        // When the user manually refreshes the bloc state, emit an error state if they were wrong.
        yield VerifyEmailError(message: "We haven't received your verification yet.");
      }

      if (event is VerifyEmailResendRequested) {
        unawaited(_userRepository.sendEmailVerification());
      }

      yield VerifyEmailValue(verified: _userRepository.user.verified);
    }
  }
}
