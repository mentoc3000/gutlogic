import 'package:equatable/equatable.dart';

import '../../models/application_user.dart';
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
  final ApplicationUser user;

  AccountUpdate({required this.user});

  @override
  List<Object?> get props => [user];

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('profile_updated');

  @override
  String toString() => 'AccountUpdate { user.id: ${user.id} }';
}

class AccountLogOut extends AccountEvent implements TrackedEvent {
  @override
  void track(AnalyticsService analytics) => analytics.logEvent('log_out');
}

class AccountDelete extends AccountEvent {}
