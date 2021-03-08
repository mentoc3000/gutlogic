import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:built_collection/built_collection.dart';
import '../../models/food/custom_food.dart';
import '../../models/food/edamam_food.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';
import '../searchable/searchable_event.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class StreamFoodQuery extends FoodEvent with FetchQuery, DebouncedEvent implements TrackedEvent {
  @override
  final String query;

  const StreamFoodQuery(this.query);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('food_search');
}

class CreateCustomFood extends FoodEvent implements TrackedEvent {
  final String foodName;

  const CreateCustomFood(this.foodName);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('create_custom_food');
}

class DeleteCustomFood extends FoodEvent implements TrackedEvent {
  final CustomFood customFood;

  const DeleteCustomFood(this.customFood);

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_custom_food');
}

class LoadFoods extends FoodEvent {
  final BuiltList<CustomFood> customFoods;
  final BuiltList<EdamamFood> edamamFoods;

  const LoadFoods({@required this.customFoods, @required this.edamamFoods});

  @override
  List<Object> get props => [customFoods, edamamFoods];

  @override
  String toString() => 'LoadFoods { customFoods: ${customFoods.length}, edamamFoods: ${edamamFoods.length} }';
}

class ThrowFoodError extends FoodEvent with ErrorEvent {
  @override
  final Object error;

  @override
  final StackTrace trace;

  const ThrowFoodError({@required this.error, @required this.trace});
}
