import 'package:equatable/equatable.dart';

import '../../resources/firebase/analytics_service.dart';

abstract class VerifyEmailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Added when the bloc automatically refreshes its own state.
class VerifyEmailAutoRefreshed extends VerifyEmailEvent {}

/// Added when the user manually refreshes the state because they claim to have verified their account.
class VerifyEmailUserRefreshed extends VerifyEmailEvent {}

/// Added when the user exits the verification page
class VerifyEmailExitRequested extends VerifyEmailEvent {}

/// Added when the user resends the email verification
class VerifyEmailResendRequested extends VerifyEmailEvent {}

/// Added when email verification is confirmed
class VerifyEmailConfirmed extends VerifyEmailEvent implements Tracked {
  @override
  void track(AnalyticsService analytics) => analytics.logEvent('email_verified');
}
