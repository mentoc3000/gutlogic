import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'food_search_event.dart';
import 'food_search_state.dart';

class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> with StreamSubscriber {
  final FoodService foodService;

  FoodSearchBloc({required this.foodService}) : super(FoodSearchLoading());

  factory FoodSearchBloc.fromContext(BuildContext context) => FoodSearchBloc(foodService: context.read<FoodService>());

  @override
  Stream<Transition<FoodSearchEvent, FoodSearchState>> transformEvents(
    Stream<FoodSearchEvent> events,
    TransitionFunction<FoodSearchEvent, FoodSearchState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<FoodSearchState> mapEventToState(FoodSearchEvent event) async* {
    try {
      if (event is StreamFoodQuery) {
        // Don't create a new stream if the query is the same
        if (state is Query && (state as Query).query == event.query) return;

        // TODO: remove these loading pages? Or maybe only show them if the fetch takes a long time.
        // https://stackoverflow.com/questions/64885470/can-dart-streams-emit-a-value-if-the-stream-is-not-done-within-a-duration/64978139
        // This should be implemented as a general feature that could be applied to many blocs
        yield FoodSearchLoading();

        await streamSubscription?.cancel();

        streamSubscription = foodService.streamQuery(event.query).listen(
              (foods) => add(LoadFoods(query: event.query, foods: foods)),
              onError: (error, StackTrace trace) => add(ThrowFoodSearchError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadFoods) {
        final foods = event.foods;
        if (foods.isEmpty) {
          yield NoFoodsFound(query: event.query);
        } else {
          yield FoodSearchLoaded(query: event.query, items: foods);
        }
      }
      if (event is CreateCustomFood) {
        unawaited(foodService.add(name: event.foodName));
      }
      if (event is DeleteCustomFood) {
        unawaited(foodService.delete(event.customFood));
      }
      if (event is ThrowFoodSearchError) {
        yield FoodSearchError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield FoodSearchError.fromError(error: error, trace: trace);
    }
  }
}
