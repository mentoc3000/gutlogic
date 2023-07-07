import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/elementary_food.dart';
import '../../resources/irritant_service.dart';
import '../bloc_helpers.dart';
import 'similar_foods_state.dart';

class SimilarFoodsCubit extends Cubit<SimilarFoodsState>
    with StreamSubscriber<BuiltList<ElementaryFood>, SimilarFoodsState> {
  final FoodReference food;
  final IrritantService irritantService;
  StreamSubscription<BuiltMap<FoodReference, Intensity>>? maxIntensitySubscription;

  SimilarFoodsCubit({
    required this.food,
    required this.irritantService,
  }) : super(const SimilarFoodsLoading()) {
    streamSubscription = irritantService.similar(food).listen(_onData, onError: _onError);
  }

  factory SimilarFoodsCubit.fromContext(BuildContext context, {required FoodReference food}) {
    return SimilarFoodsCubit(
      food: food,
      irritantService: context.read<IrritantService>(),
    );
  }

  void _onData(BuiltList<ElementaryFood> foods) async {
    // Get the irritants in each food
    final irritantsList = foods.map((f) => f.irritants);
    final foodReferences = foods.map((f) => f.canonical).whereType<FoodReference>().toBuiltList();

    // Compute the irritant doses for a single serving of each food
    final doses = irritantsList.map(IrritantService.doseMap);

    // Get the maximum intensity for each food
    await maxIntensitySubscription?.cancel();
    maxIntensitySubscription = CombineLatestStream(
      doses.map((d) => irritantService.maxIntensity(d, usePreferences: true)),
      (maxIntensities) => BuiltMap<FoodReference, Intensity>(Map.fromIterables(foodReferences, maxIntensities)),
    ).listen(
      (maxIntensitiesMap) {
        if (!isClosed) {
          emit(SimilarFoodsLoaded(foods: foodReferences, maxIntensities: maxIntensitiesMap));
        }
      },
      onError: _onError,
    );
  }

  void _onError(Object error, StackTrace trace) {
    if (!isClosed) {
      emit(SimilarFoodsError.fromError(error: error, trace: trace));
    }
  }

  @override
  Future<void> close() {
    maxIntensitySubscription?.cancel();
    streamSubscription?.cancel();
    return super.close();
  }
}
