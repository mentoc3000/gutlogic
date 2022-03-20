import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../resources/food/food_service.dart';
import '../bloc_helpers.dart';
import 'food_search_event.dart';
import 'food_search_state.dart';

class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> with StreamSubscriber {
  final FoodService foodService;

  FoodSearchBloc({required this.foodService}) : super(FoodSearchLoading()) {
    on<StreamFoodQuery>(_onStreamFoodQuery, transformer: debounceTransformer);
    on<LoadFoods>(_onLoadFoods);
    on<CreateCustomFood>((event, emit) => unawaited(foodService.add(name: event.foodName)));
    on<DeleteCustomFood>((event, emit) => unawaited(foodService.delete(event.customFood)));
    on<ThrowFoodSearchError>((event, emit) => emit(FoodSearchError.fromReport(event.report)));
  }

  static FoodSearchBloc fromContext(BuildContext context) => FoodSearchBloc(foodService: context.read<FoodService>());

  void _onLoadFoods(LoadFoods event, Emitter<FoodSearchState> emit) {
    try {
      final foods = event.foods;
      if (foods.isEmpty) {
        emit(NoFoodsFound(query: event.query));
      } else {
        emit(FoodSearchLoaded(query: event.query, items: foods));
      }
    } catch (error, trace) {
      emit(FoodSearchError.fromError(error: error, trace: trace));
    }
  }

  Future<void> _onStreamFoodQuery(StreamFoodQuery event, Emitter<FoodSearchState> emit) async {
    try {
      // Don't create a new stream if the query is the same
      if (state is Query && (state as Query).query == event.query) return;

      // TODO: remove these loading pages? Or maybe only show them if the fetch takes a long time.
      // https://stackoverflow.com/questions/64885470/can-dart-streams-emit-a-value-if-the-stream-is-not-done-within-a-duration/64978139
      // This should be implemented as a general feature that could be applied to many blocs
      emit(FoodSearchLoading());

      await streamSubscription?.cancel();

      streamSubscription = foodService.streamQuery(event.query).listen(
            (foods) => add(LoadFoods(query: event.query, foods: foods)),
            onError: (error, StackTrace trace) => add(ThrowFoodSearchError.fromError(error: error, trace: trace)),
          );
    } catch (error, trace) {
      emit(FoodSearchError.fromError(error: error, trace: trace));
    }
  }
}
