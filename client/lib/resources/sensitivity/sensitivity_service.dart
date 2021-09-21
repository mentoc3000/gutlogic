import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity.dart';
import '../../resources/sensitivity/sensitivity_repository.dart';
import 'heuristic_sensitivity_prediction_service.dart';

class SensitivityService extends ChangeNotifier {
  final SensitivityRepository sensitivityRepository;
  final HeuristicSensitivityPredictionService? heuristicPredictionService;

  final Map<FoodReference, Sensitivity> _cache = <FoodReference, Sensitivity>{};

  SensitivityService({required this.sensitivityRepository, this.heuristicPredictionService}) {
    final sensitivityMapStream = sensitivityRepository.streamAll();
    sensitivityMapStream.listen(_cacheSensitivityEntries);
    heuristicPredictionService?.onChange(notifyListeners);
  }

  void _cacheSensitivityEntries(BuiltMap<FoodReference, Sensitivity> entries) {
    _cache.clear(); // TODO this would be improved by the repository streaming additions and deletions
    _cache.addAll(entries.toMap());

    notifyListeners();
  }

  Future<Sensitivity> ofRef(FoodReference food) async {
    return _cache[food] ?? (await heuristicPredictionService?.predictFromRef(food)) ?? Sensitivity.unknown;
  }

  Sensitivity ofFood(Food food) {
    return _cache[food.toFoodReference()] ?? heuristicPredictionService?.predictFromFood(food) ?? Sensitivity.unknown;
  }

  Future<Sensitivity> aggregateByRef(Iterable<FoodReference> foods) async {
    final sensitivities = await Future.wait(foods.map(ofRef));
    return Sensitivity.aggregate(sensitivities);
  }

  Sensitivity aggregateByFood(Iterable<Food> foods) {
    final sensitivities = foods.map(ofFood);
    return Sensitivity.aggregate(sensitivities);
  }
}
