import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

import '../../resources/food/custom_food_repository.dart';
import '../../resources/food/edamam_food_repository.dart';
import '../bloc_helpers.dart';
import 'food_event.dart';
import 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> with StreamSubscriber {
  final CustomFoodRepository customFoodRepository;
  final EdamamFoodRepository edamamFoodRepository;

  FoodBloc({@required this.customFoodRepository, @required this.edamamFoodRepository});

  factory FoodBloc.fromContext(BuildContext context) => FoodBloc(
        customFoodRepository: context.repository<CustomFoodRepository>(),
        edamamFoodRepository: context.repository<EdamamFoodRepository>(),
      );

  @override
  FoodState get initialState => FoodsLoading();

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
        // TODO: remove these loading pages? Or maybe only show them if the fetch takes a long time.
        // https://stackoverflow.com/questions/64885470/can-dart-streams-emit-a-value-if-the-stream-is-not-done-within-a-duration/64978139
        // This should be implemented as a general feature that could be applied to many blocs
        yield FoodsLoading();
        await streamSubscription?.cancel();
        final customFoodStream = customFoodRepository.streamQuery(event.query);
        final edamamFoodStream = edamamFoodRepository.streamQuery(event.query);
        final combinedStream = CombineLatestStream(
          [customFoodStream, edamamFoodStream],
          (values) => {'custom': values.first, 'edamam': values.last},
        );
        streamSubscription = combinedStream.listen(
          (foods) => add(LoadFoods(customFoods: foods['custom'], edamamFoods: foods['edamam'])),
          onError: (error, StackTrace trace) => add(ThrowFoodError(error: error, trace: trace)),
        );
      }
      if (event is LoadFoods) {
        final customFoods = event.customFoods;
        final edamamFoods = event.edamamFoods;
        if (customFoods.isEmpty && edamamFoods.isEmpty) {
          yield NoFoodsFound();
        } else {
          yield FoodsLoaded(customFoods: customFoods, edamamFoods: edamamFoods);
        }
      }
      if (event is CreateCustomFood) {
        unawaited(customFoodRepository.add(name: event.foodName));
      }
      if (event is DeleteCustomFood) {
        unawaited(customFoodRepository.delete(event.customFood));
      }
      if (event is ThrowFoodError) {
        yield FoodError.fromError(error: event.error, trace: event.trace);
      }
    } catch (error, trace) {
      yield FoodError.fromError(error: error, trace: trace);
    }
  }
}
