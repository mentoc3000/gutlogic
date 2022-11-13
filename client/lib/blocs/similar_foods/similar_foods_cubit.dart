import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/models/irritant/intensity.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/irritant/elementary_food.dart';
import '../../resources/irritant_service.dart';
import '../bloc_helpers.dart';
import 'similar_foods_state.dart';

class SimilarFoodsCubit extends Cubit<SimilarFoodsState>
    with StreamSubscriber<BuiltList<FoodReference>, SimilarFoodsState> {
  final FoodReference food;
  final IrritantService irritantService;

  SimilarFoodsCubit({
    required this.food,
    required this.irritantService,
  }) : super(const SimilarFoodsLoading()) {
    irritantService.similar(food).then(_onData, onError: _onError);
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
    final doses = irritantsList.map((ii) => BuiltMap<String, double>({for (var i in ii) i.name: i.dosePerServing}));

    // Get the maximum intensity for each food
    final maxIntensities = await Future.wait(doses.map((d) async => await irritantService.maxIntensity(d)));
    final maxIntensitiesMap = BuiltMap<FoodReference, Intensity>(Map.fromIterables(foodReferences, maxIntensities));

    emit(SimilarFoodsLoaded(foods: foodReferences, maxIntensities: maxIntensitiesMap));
  }

  void _onError(Object error, StackTrace trace) {
    emit(SimilarFoodsError.fromError(error: error, trace: trace));
  }
}
