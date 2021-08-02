import 'package:equatable/equatable.dart';

import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class AccountUpdate extends AccountEvent implements TrackedEvent {
  final String firstname;
  final String lastname;

  AccountUpdate({required this.firstname, required this.lastname});

  @override
  List<Object?> get props => [firstname, lastname];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('profile_updated');
}

class AccountLogOut extends AccountEvent implements TrackedEvent {
  @override
  void track(AnalyticsService analytics) => analytics.logEvent('log_out');
}

class AccountDelete extends AccountEvent {}
