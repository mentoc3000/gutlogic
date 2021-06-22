import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'food_event.dart';
import 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> with StreamSubscriber {
  final FoodService foodService;

  FoodBloc({required this.foodService}) : super(FoodsLoading());

  factory FoodBloc.fromContext(BuildContext context) => FoodBloc(foodService: context.read<FoodService>());

  @override
  Stream<Transition<FoodEvent, FoodState>> transformEvents(
    Stream<FoodEvent> events,
    TransitionFunction<FoodEvent, FoodState> transition,
  ) =>
      super.transformEvents(debounceDebouncedByType(events), transition);

  @override
  Stream<FoodState> mapEventToState(FoodEvent event) async* {
    try {
      if (event is StreamFoodQuery) {
        // Don't create a new stream if the query is the same
        if (state is Query && (state as Query).query == event.query) return;

        // TODO: remove these loading pages? Or maybe only show them if the fetch takes a long time.
        // https://stackoverflow.com/questions/64885470/can-dart-streams-emit-a-value-if-the-stream-is-not-done-within-a-duration/64978139
        // This should be implemented as a general feature that could be applied to many blocs
        yield FoodsLoading();

        await streamSubscription?.cancel();

        streamSubscription = foodService.streamQuery(event.query).listen(
              (foods) => add(LoadFoods(query: event.query, foods: foods)),
              onError: (error, StackTrace trace) => add(ThrowFoodError.fromError(error: error, trace: trace)),
            );
      }
      if (event is LoadFoods) {
        final foods = event.foods;
        if (foods.isEmpty) {
          yield NoFoodsFound(query: event.query);
        } else {
          yield FoodsLoaded(query: event.query, items: foods);
        }
      }
      if (event is CreateCustomFood) {
        unawaited(foodService.add(name: event.foodName));
      }
      if (event is DeleteCustomFood) {
        unawaited(foodService.delete(event.customFood));
      }
      if (event is ThrowFoodError) {
        yield FoodError.fromReport(event.report);
      }
    } catch (error, trace) {
      yield FoodError.fromError(error: error, trace: trace);
    }
  }
}
