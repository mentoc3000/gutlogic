import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/symptom_type.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

abstract class SymptomTypeEvent extends Equatable {
  const SymptomTypeEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class FetchAllSymptomTypes extends SymptomTypeEvent with FetchAll implements Tracked {
  const FetchAllSymptomTypes();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('symptom_type_search');
}

class FetchSymptomTypeQuery extends SymptomTypeEvent with FetchQuery implements Tracked {
  @override
  final String query;

  const FetchSymptomTypeQuery(this.query);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('symptom_type_search');
}

class StreamAllSymptomTypes extends SymptomTypeEvent with StreamAll implements Tracked {
  const StreamAllSymptomTypes();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('symptom_type_search');
}

class StreamSymptomTypeQuery extends SymptomTypeEvent with StreamQuery implements Tracked {
  @override
  final String query;

  const StreamSymptomTypeQuery(this.query);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('symptom_type_search');
}

class LoadSymptomTypes extends SymptomTypeEvent with LoadSearchables {
  @override
  final BuiltList<SymptomType> items;

  const LoadSymptomTypes(this.items);
}

class ThrowSymptomTypeError extends SymptomTypeEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowSymptomTypeError({required this.report});

  factory ThrowSymptomTypeError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowSymptomTypeError(report: ErrorReport(error: error, trace: trace));
}
