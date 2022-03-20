import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

abstract class FoodSearchEvent extends Equatable {
  const FoodSearchEvent();

  @override
  List<Object?> get props => [];
}

class StreamFoodQuery extends FoodSearchEvent with FetchQuery implements Tracked {
  @override
  final String query;

  const StreamFoodQuery(this.query);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('food_search');
}

class CreateCustomFood extends FoodSearchEvent implements Tracked {
  final String foodName;

  const CreateCustomFood(this.foodName);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('create_custom_food');
}

class DeleteCustomFood extends FoodSearchEvent implements Tracked {
  final CustomFood customFood;

  const DeleteCustomFood(this.customFood);

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_custom_food');
}

class LoadFoods extends FoodSearchEvent {
  final String query;
  final BuiltList<Food> foods;

  const LoadFoods({required this.query, required this.foods});

  @override
  List<Object?> get props => [query, foods];
}

class ThrowFoodSearchError extends FoodSearchEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowFoodSearchError({required this.report});

  factory ThrowFoodSearchError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowFoodSearchError(report: ErrorReport(error: error, trace: trace));
}
