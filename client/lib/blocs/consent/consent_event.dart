import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../resources/firebase/analytics_service.dart';

@immutable
abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class ConsentSubmitted extends ConsentEvent implements Tracked {
  const ConsentSubmitted();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('consented');
}
