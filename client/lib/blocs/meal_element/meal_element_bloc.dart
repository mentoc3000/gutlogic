import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../resources/diary_repositories/meal_element_repository.dart';
import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'meal_element_event.dart';
import 'meal_element_state.dart';

class MealElementBloc extends Bloc<MealElementEvent, MealElementState> with StreamSubscriber {
  final MealElementRepository mealElementRepository;
  final FoodService foodService;

  MealElementBloc({required this.mealElementRepository, required this.foodService}) : super(MealElementLoading());

  factory MealElementBloc.fromContext(BuildContext context) {
    return MealElementBloc(
      mealElementRepository: context.read<MealElementRepository>(),
      foodService: context.read<FoodService>(),
    );
  }

  @override
  Stream<Transition<MealElementEvent, MealElementState>> transformEvents(
    Stream<MealElementEvent> events,
    TransitionFunction<MealElementEvent, MealElementState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<MealElementState> mapEventToState(
    MealElementEvent event,
  ) async* {
    try {
      if (event is StreamMealElement) {
        var mealElement = event.mealElement;
        Food? food;

        // If the meal element uses an Edamam food, fetch that food to get the measure options
        if (mealElement.foodReference is EdamamFoodReference) {
          // TODO: load meal element without food first
          yield MealElementLoading();
          food = await foodService.streamFood(mealElement.foodReference).first;

          // If the meal element doesn't have a measure yet, set it to the first option
          if (mealElement.quantity?.measure == null && (food?.measures.isNotEmpty ?? false)) {
            mealElement = mealElement.rebuild((b) => b..quantity.measure = food!.measures.first.toBuilder());
            add(Update(mealElement));
          }
        }

        yield MealElementLoaded(mealElement: mealElement, food: food);

        // Subscribe to the stream, updating the mealElement but using the same food value, which cannot change.
        streamSubscription = mealElementRepository.stream(event.mealElement).listen(
              (mealElement) => add(Load(mealElement: mealElement!, food: food)),
              onError: (error, StackTrace trace) => add(ThrowMealElementError.fromError(error: error, trace: trace)),
            );
      }
      if (event is Load) {
        yield MealElementLoaded(mealElement: event.mealElement, food: event.food);
      }
      if (event is Delete) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.delete(mealElement));
      }
      if (event is Update) {
        unawaited(mealElementRepository.update(event.mealElement));
      }
      if (event is UpdateQuantity) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.updateQuantity(mealElement, event.quantity));
      }
      if (event is UpdateNotes) {
        final mealElement = (state as MealElementLoaded).mealElement;
        unawaited(mealElementRepository.updateNotes(mealElement, event.notes));
      }
      if (event is ThrowMealElementError) {
        yield MealElementError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield MealElementError.fromError(error: error, trace: trace);
    }
  }
}
