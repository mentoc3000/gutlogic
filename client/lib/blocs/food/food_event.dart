import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class StreamFoodQuery extends FoodEvent with FetchQuery, DebouncedEvent implements TrackedEvent {
  @override
  final String query;

  const StreamFoodQuery(this.query);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('food_search');
}

class CreateCustomFood extends FoodEvent implements TrackedEvent {
  final String foodName;

  const CreateCustomFood(this.foodName);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_custom_food');
}

class DeleteCustomFood extends FoodEvent implements TrackedEvent {
  final CustomFood customFood;

  const DeleteCustomFood(this.customFood);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_custom_food');
}

class LoadFoods extends FoodEvent {
  final String query;
  final BuiltList<Food> foods;

  const LoadFoods({required this.query, required this.foods});

  @override
  List<Object?> get props => [query, foods];

  @override
  String toString() => 'LoadFoods { foods: ${foods.length} }';
}

class ThrowFoodError extends FoodEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowFoodError({required this.report});

  factory ThrowFoodError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowFoodError(report: ErrorReport(error: error, trace: trace));
}
