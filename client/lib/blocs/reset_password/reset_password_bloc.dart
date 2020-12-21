import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../resources/user_repository.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final UserRepository userRepository;

  ResetPasswordBloc({this.userRepository});

  factory ResetPasswordBloc.fromContext(BuildContext context) => ResetPasswordBloc(
        userRepository: context.repository<UserRepository>(),
      );

  @override
  ResetPasswordState get initialState => const ResetPasswordReady();

  @override
  Stream<ResetPasswordState> mapEventToState(ResetPasswordEvent event) async* {
    if (event is ResetPasswordSubmitted) {
      yield* _mapSubmittedToState(event);
    }
  }

  Stream<ResetPasswordState> _mapSubmittedToState(ResetPasswordSubmitted event) async* {
    try {
      yield const ResetPasswordLoading();
      await userRepository.resetPassword(email: event.email);
      yield ResetPasswordSuccess(email: event.email);
    } on MissingUserException {
      // We yield the success state even if the email isn't associated with an account because we don't want to leak
      // information about which emails are registered with us.
      yield ResetPasswordSuccess(email: event.email);
    } catch (error, trace) {
      yield ResetPasswordError.fromError(error: error, trace: trace);
      yield const ResetPasswordReady();
    }
  }
}
