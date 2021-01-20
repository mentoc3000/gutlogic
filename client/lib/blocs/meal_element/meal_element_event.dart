import 'package:equatable/equatable.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/meal_element.dart';
import '../../models/quantity.dart';
import '../../resources/firebase/analytics_service.dart';
import '../bloc_helpers.dart';

abstract class MealElementEvent extends Equatable {
  const MealElementEvent();

  @override
  List<Object> get props => [];
}

class Load extends MealElementEvent {
  final MealElement mealElement;

  const Load(this.mealElement);

  @override
  List<Object> get props => [mealElement];

  @override
  String toString() => 'Load { mealElementId : ${mealElement?.id} }';
}

class Delete extends MealElementEvent implements TrackedEvent {
  const Delete();

  @override
  String toString() => 'Delete';

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logEvent('delete_meal_element');
}

class StreamMealElement extends MealElementEvent {
  final MealElement mealElement;

  const StreamMealElement(this.mealElement);

  @override
  List<Object> get props => [mealElement];

  @override
  String toString() => 'StreamMealElement { mealElementId : ${mealElement?.id} }';
}

class Update extends MealElementEvent with DebouncedEvent implements TrackedEvent {
  final MealElement mealElement;

  const Update(this.mealElement);

  @override
  List<Object> get props => [mealElement];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_element');

  @override
  String toString() => 'Update { mealElementId : ${mealElement?.id} }';
}

class UpdateQuantity extends MealElementEvent with DebouncedEvent implements TrackedEvent {
  final Quantity quantity;

  const UpdateQuantity(this.quantity);

  @override
  List<Object> get props => [quantity];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_element', 'quantity');

  @override
  String toString() => 'Update { quantity: $quantity }';
}

class UpdateNotes extends MealElementEvent with DebouncedEvent implements TrackedEvent {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object> get props => [notes];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_element', 'notes');

  @override
  String toString() => 'Update { notes: $notes }';
}

class UpdateFoodReference extends MealElementEvent with DebouncedEvent implements TrackedEvent {
  final FoodReference foodReference;

  const UpdateFoodReference(this.foodReference);

  @override
  List<Object> get props => [foodReference];

  @override
  void track(AnalyticsService analyticsService) => analyticsService.logUpdateEvent('update_meal_element', 'food');

  @override
  String toString() => 'Update { food: ${foodReference.name} }';
}

class Loading extends MealElementEvent {
  @override
  String toString() => 'Loading';
}

class Throw extends MealElementEvent {
  final Error error;
  final StackTrace trace;

  const Throw({this.error, this.trace});

  @override
  List<Object> get props => [error, trace];

  @override
  String toString() => 'Throw { error: $error }';
}
