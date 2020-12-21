import 'package:equatable/equatable.dart';

abstract class VerifyEmailEvent extends Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

/// Added when the bloc automatically refreshes its own state.
class VerifyEmailAutoRefreshed extends VerifyEmailEvent {}

/// Added when the user manually refreshes the state because they claim to have verified their account.
class VerifyEmailUserRefreshed extends VerifyEmailEvent {}

/// Added when the user exits the verification page
class VerifyEmailExitRequested extends VerifyEmailEvent {}

/// Added when the user resends the email verification
class VerifyEmailResendRequested extends VerifyEmailEvent {}
