import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import '../../models/symptom_type.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

abstract class SymptomTypeEvent extends Equatable {
  const SymptomTypeEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class FetchAllSymptomTypes extends SymptomTypeEvent with FetchAll implements TrackedEvent {
  const FetchAllSymptomTypes();

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('symptom_type_search');
}

class FetchSymptomTypeQuery extends SymptomTypeEvent with FetchQuery implements TrackedEvent {
  @override
  final String query;

  const FetchSymptomTypeQuery(this.query);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('symptom_type_search');
}

class StreamAllSymptomTypes extends SymptomTypeEvent with StreamAll implements TrackedEvent {
  const StreamAllSymptomTypes();

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('symptom_type_search');
}

class StreamSymptomTypeQuery extends SymptomTypeEvent with StreamQuery implements TrackedEvent {
  @override
  final String query;

  const StreamSymptomTypeQuery(this.query);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('symptom_type_search');
}

class LoadSymptomTypes extends SymptomTypeEvent with LoadSearchables {
  @override
  final BuiltList<SymptomType> items;

  const LoadSymptomTypes(this.items);
}

class ThrowSymptomTypeError extends SymptomTypeEvent with ThrowSearchableError {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowSymptomTypeError({@required this.error, @required this.trace});
}
