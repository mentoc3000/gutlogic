import 'package:equatable/equatable.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/meal_element.dart';
import '../../models/quantity.dart';
import '../../resources/firebase/analytics_service.dart';
import '../../util/error_report.dart';
import '../bloc_helpers.dart';

abstract class MealElementEvent extends Equatable {
  const MealElementEvent();

  @override
  List<Object?> get props => [];
}

class Load extends MealElementEvent {
  final MealElement mealElement;
  final Food? food;

  const Load({required this.mealElement, this.food});

  @override
  List<Object?> get props => [mealElement, food];
}

class Delete extends MealElementEvent implements Tracked {
  const Delete();

  @override
  void track(AnalyticsService analytics) => analytics.logEvent('delete_meal_element');
}

class StreamMealElement extends MealElementEvent {
  final MealElement mealElement;

  const StreamMealElement(this.mealElement);

  @override
  List<Object?> get props => [mealElement];
}

class Update extends MealElementEvent with DebouncedEvent implements Tracked {
  final MealElement mealElement;

  const Update(this.mealElement);

  @override
  List<Object?> get props => [mealElement];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_element');
}

class UpdateQuantity extends MealElementEvent with DebouncedEvent implements Tracked {
  final Quantity quantity;

  const UpdateQuantity(this.quantity);

  @override
  List<Object?> get props => [quantity];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_element', 'quantity');
}

class UpdateNotes extends MealElementEvent with DebouncedEvent implements Tracked {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_element', 'notes');
}

class UpdateFoodReference extends MealElementEvent with DebouncedEvent implements Tracked {
  final FoodReference foodReference;

  const UpdateFoodReference(this.foodReference);

  @override
  List<Object?> get props => [foodReference];

  @override
  void track(AnalyticsService analytics) => analytics.logUpdateEvent('update_meal_element', 'food');
}

class Loading extends MealElementEvent {}

class ThrowMealElementError extends MealElementEvent with ErrorEvent {
  @override
  final ErrorReport report;

  const ThrowMealElementError({required this.report});

  factory ThrowMealElementError.fromError({required dynamic error, required StackTrace trace}) =>
      ThrowMealElementError(report: ErrorReport(error: error, trace: trace));
}
