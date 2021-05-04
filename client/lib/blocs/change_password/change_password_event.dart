import 'package:equatable/equatable.dart';

import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class ChangePasswordEvent extends Equatable {
  ChangePasswordEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ChangePasswordSubmitted extends ChangePasswordEvent implements TrackedEvent {
  /// The user's current password. This can be null if the user does not have a password provider.
  final String currentPassword;

  /// The user's updated password.
  final String updatedPassword;

  ChangePasswordSubmitted({
    required this.currentPassword,
    required this.updatedPassword,
  });

  @override
  List<Object?> get props => [currentPassword, updatedPassword];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('password_change');

  // TODO remove password value logging in production
}
