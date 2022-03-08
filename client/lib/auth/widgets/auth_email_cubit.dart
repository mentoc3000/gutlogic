import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth.dart';
import '../services/auth_email.dart';
import 'auth_email_state.dart';

export 'auth_email_state.dart';

/// Handles authentication via email links.
class AuthEmailCubit extends Cubit<AuthEmailState> {
  final Function(Authentication) onAuthentication;

  StreamSubscription? _pendingAuthenticationSubscription;

  AuthEmailCubit({required this.onAuthentication}) : super(const AuthEmailInitial());

  static BlocProvider<AuthEmailCubit> provider({
    required Function(Authentication) onAuthentication,
    required Widget child,
  }) {
    return BlocProvider<AuthEmailCubit>(
      create: (c) => AuthEmailCubit(onAuthentication: onAuthentication),
      child: child,
    );
  }

  /// Request authentication via email. The authentication can be cancelled by [cancel].
  Future<void> authenticate({required EmailAuthService service, required String email}) async {
    if (state is! AuthEmailInitial) return;

    emit(AuthEmailAwaitingLink(email: email));

    try {
      await service.sendAuthenticationLink(email);
    } on InvalidEmailException {
      return emit(const AuthEmailInitial());
    }

    _pendingAuthenticationSubscription = service.streamAuthenticationForEmail(email).listen(onAuthentication);
  }

  /// Cancel the pending authentication.
  void cancel() {
    if (state is! AuthEmailAwaitingLink) return;

    if (_pendingAuthenticationSubscription != null) {
      // TODO use unawaited(_pendingAuthenticationSubscription?.cancel()) in Flutter 2.10
      unawaited(_pendingAuthenticationSubscription!.cancel());
      _pendingAuthenticationSubscription = null;
    }

    emit(const AuthEmailInitial());
  }

  @override
  Future<void> close() async {
    await _pendingAuthenticationSubscription?.cancel();
    await super.close();
  }
}
