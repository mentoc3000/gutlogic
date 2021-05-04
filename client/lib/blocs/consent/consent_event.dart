import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

@immutable
abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class ConsentSubmitted extends ConsentEvent implements TrackedEvent {
  const ConsentSubmitted();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('consented');
}
