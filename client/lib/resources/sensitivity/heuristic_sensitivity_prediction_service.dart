import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../models/sensitivity/sensitivity_source.dart';
import '../food/food_service.dart';
import 'models/reaction.dart';
import 'models/sensitivity_profile.dart';

class HeuristicSensitivityPredictionService {
  final FoodService foodService;
  late final BehaviorSubject<SensitivityProfile> _behaviorSubject;
  SensitivityProfile get sensitivityProfile => _behaviorSubject.valueOrNull ?? SensitivityProfile.unknown();

  Map<FoodReference, Sensitivity> _sensitivityEntries = <FoodReference, Sensitivity>{};
  final Map<FoodReference, Map<String, Reaction>> _reactionCache = <FoodReference, Map<String, Reaction>>{};

  HeuristicSensitivityPredictionService({
    required this.foodService,
    required Stream<BuiltMap<FoodReference, Sensitivity>> sensitivityMapStream,
  }) {
    _behaviorSubject = BehaviorSubject();
    // Cast to Iterable to fix switchMap type matches at runtime
    final sensitivityProfileStream =
        sensitivityMapStream.cast<BuiltMap<FoodReference, Sensitivity>>().asyncMap(_profilePantry);
    _behaviorSubject.addStream(sensitivityProfileStream);
  }

  Future<Map<FoodReference, Map<String, Reaction>>> _getReactionMaps(
      BuiltMap<FoodReference, Sensitivity> latestSensitivityEntries) async {
    final oldFoodReferences = _reactionCache.keys.toSet();
    final latestFoodReferences = latestSensitivityEntries.keys.toSet();

    // Delete old food references
    final keysToDelete = oldFoodReferences.difference(latestFoodReferences);
    keysToDelete.forEach(_reactionCache.remove);

    // Add new or updated food references
    final upsertedFoodRefs =
        latestSensitivityEntries.entries.where((e) => _sensitivityEntries[e.key] != e.value).map((e) => e.key);
    final newFoods = await Future.wait(upsertedFoodRefs.map((f) => foodService.streamFood(f).first));
    final reactionMaps = newFoods
        .whereNotNull()
        .map((f) => getReactions(food: f, sensitivityLevel: latestSensitivityEntries[f.toFoodReference()]!.level));

    final additions = Map.fromIterables(upsertedFoodRefs, reactionMaps);
    _reactionCache.addAll(additions);
    _sensitivityEntries = latestSensitivityEntries.toMap();

    return _reactionCache;
  }

  Future<SensitivityProfile> _profilePantry(BuiltMap<FoodReference, Sensitivity> sensitivityEntries) async {
    final reactionMaps = await _getReactionMaps(sensitivityEntries);
    final irritantNames =
        reactionMaps.values.fold<Set<String>>({}, (acc, element) => acc..addAll(element.keys)).toList();
    final reactions = irritantNames.map((i) => reactionMaps.values.where((m) => m.containsKey(i)).map((e) => e[i]!));
    final census = Map.fromIterables(irritantNames, reactions);
    return SensitivityProfile.fromCensus(census);
  }

  Sensitivity predictFromFood(Food food) {
    final sensitivityLevel = sensitivityProfile.evaluateFood(food);
    return Sensitivity(level: sensitivityLevel, source: SensitivitySource.prediction);
  }

  Future<Sensitivity> predictFromRef(FoodReference foodReference) async {
    final food = await foodService.streamFood(foodReference).first;
    final sensitivityLevel = food == null ? SensitivityLevel.unknown : sensitivityProfile.evaluateFood(food);
    return Sensitivity(level: sensitivityLevel, source: SensitivitySource.prediction);
  }

  void onChange(void Function() callback) {
    _behaviorSubject.listen((value) {
      callback();
    });
  }
}

/// Map irritant name to reaction
Map<String, Reaction> getReactions({required Food food, required SensitivityLevel sensitivityLevel}) {
  final irritants = food.irritants?.where((i) => i.concentration != null);
  if (irritants == null) return {};

  final servingSize = food.measures.firstWhereOrNull((m) => m.unit == 'Serving')?.weight ?? Reaction.defaultServingSize;

  return {
    for (final i in irritants)
      i.name: Reaction(dose: i.concentration! * servingSize, sensitivityLevel: sensitivityLevel)
  };
}
