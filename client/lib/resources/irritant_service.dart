import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/food_reference/food_reference.dart';
import '../models/irritant/elementary_food.dart';
import '../models/irritant/intensity.dart';
import '../models/irritant/intensity_thresholds.dart';
import '../models/irritant/irritant.dart';
import '../models/serializers.dart';
import '../util/math.dart';
import 'api_service.dart';
import 'firebase/firestore_service.dart';

class IrritantService {
  final ApiService apiService;
  late final Future<BuiltMap<String, BuiltList<double>>> _intensityThresholdCache;
  late final Future<BuiltList<ElementaryFood>> _elementaryFoodCache;

  IrritantService({required this.apiService}) {
    _elementaryFoodCache = _getElementaryFoods();
    _intensityThresholdCache = _getIntensityThresholds();
  }

  static IrritantService fromContext(BuildContext context) {
    return IrritantService(apiService: context.read<ApiService>());
  }

  Future<BuiltMap<String, BuiltList<double>>> _getIntensityThresholds() async {
    try {
      final res = await apiService.get(path: '/irritant/intensityThresholds');
      final data = res['data'] as List;
      final intensityThresholdsList = data
          .map((e) => serializers.deserializeWith(IntensityThresholds.serializer, e))
          .whereType<IntensityThresholds>();
      final names = intensityThresholdsList.map((e) => e.name);
      final thresholds = intensityThresholdsList.map((e) => e.intensitySteps);
      return BuiltMap(Map.fromIterables(names, thresholds));
    } catch (error) {
      if (error is HttpException) {
        if (error.statusCode == 401) {
          throw IrritantServiceException(message: 'API authentication error');
        } else {
          throw IrritantServiceException(message: 'API unavailable');
        }
      } else {
        throw IrritantServiceException(message: 'Unknown error');
      }
    }
  }

  Future<BuiltList<ElementaryFood>> _getElementaryFoods() async {
    try {
      final res = await apiService.get(path: '/irritant/elementaryFoods');
      final data = res['data'] as List;
      return data
          .map((e) => serializers.deserializeWith(ElementaryFood.serializer, e))
          .whereType<ElementaryFood>()
          .toBuiltList();
    } catch (error) {
      if (error is HttpException) {
        if (error.statusCode == 401) {
          throw IrritantServiceException(message: 'API authentication error');
        } else {
          throw IrritantServiceException(message: 'API unavailable');
        }
      } else {
        throw IrritantServiceException(message: 'Unknown error');
      }
    }
  }

  Future<ElementaryFood?> _getFoodIrritantsOf(FoodReference food) async {
    // Check if food is elementary
    final elementaryFoods = await _elementaryFoodCache;
    final foodIrritantsApi = elementaryFoods.cast<ElementaryFood?>().firstWhere(
          (p0) => p0?.foodIds.contains(food.id) ?? false,
          orElse: () => null,
        );
    if (foodIrritantsApi != null) {
      return foodIrritantsApi;
    }

    // TODO: query api server
    return null;
  }

  Future<BuiltList<Irritant>?> ofRef(FoodReference food) async {
    final foodIrritantsApi = await _getFoodIrritantsOf(food);
    return foodIrritantsApi?.irritants;
  }

  static Iterable<ElementaryFood?> deserialize(UntypedQuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => serializers.deserializeWith(ElementaryFood.serializer, doc.data()) as ElementaryFood);
  }

  /// Set of irritant names
  Future<BuiltSet<String>> names() async {
    final intensityThresholds = await _intensityThresholdCache;
    return intensityThresholds.keys.toBuiltSet();
  }

  /// Dose thresholds at which the intensity increases
  Future<BuiltList<double>?> intensityThresholds(String irritant) async {
    final intensityThresholds = await _intensityThresholdCache;
    return intensityThresholds[irritant];
  }

  static Intensity intensity({required double dose, required Iterable<double> intensityThresholds}) {
    if (dose == 0) return Intensity.none;

    final numThresholdsExceeded = intensityThresholds.map((t) => dose > t).fold<int>(0, (acc, tf) => acc += tf ? 1 : 0);
    switch (numThresholdsExceeded) {
      case 0:
        return Intensity.trace;
      case 1:
        return Intensity.low;
      case 2:
        return Intensity.medium;
      case 3:
        return Intensity.high;
      default:
        throw ArgumentError(numThresholdsExceeded);
    }
  }

  Future<Intensity> maxIntensity(BuiltMap<String, double> doses) async {
    var maxIntensity = Intensity.none;
    for (var doseEntry in doses.entries) {
      final irritantName = doseEntry.key;
      final dose = doseEntry.value;
      final thresholds = await intensityThresholds(irritantName);
      if (thresholds == null) continue;
      final intensity = IrritantService.intensity(dose: dose, intensityThresholds: thresholds);
      if (intensity > maxIntensity) {
        maxIntensity = intensity;
      }
    }
    return maxIntensity;
  }

  Future<BuiltList<ElementaryFood>> similar(FoodReference food) async {
    final ref = await _getFoodIrritantsOf(food);
    if (ref == null) return BuiltList<ElementaryFood>();
    final irritantNames = ref.irritants.map((i) => i.name).toSet();

    // Get foods that contain at least one irritant that food has
    final elementaryFoods = await _elementaryFoodCache;

    final foodIrritantsApi = elementaryFoods
        // Only foods that have at least one non-zero concentration of irritants
        .where((f) => f.irritants.toList().fold(false, (acc, el) => acc || el.concentration > 0))
        // Use foods that contain at least one irritant shared by the food of interest
        .where((f) => f.irritants.map((p0) => p0.name).toSet().intersection(irritantNames).isNotEmpty)
        // Only use foods with a cannonical food with irritants
        .where((f) => f.canonical != null)
        .where((f) => f.irritants.isNotEmpty)
        .toList();
    // Sort foods by similarity to the reference food
    foodIrritantsApi.sort((a, b) => irritantSimilarityCompare(ref, a, b));
    return foodIrritantsApi.toBuiltList();
  }

  /// Compare both a and b to a reference. Negative if a has a more similar irritant profile.
  static int irritantSimilarityCompare(ElementaryFood ref, ElementaryFood a, ElementaryFood b) {
    // Zero concentration is the same as no data on irritant, so remove those irritants
    ref = _removeZeroConcentration(ref);
    a = _removeZeroConcentration(a);
    b = _removeZeroConcentration(b);

    final aHasSame = _hasSameIrritants(ref, a);
    final bHasSame = _hasSameIrritants(ref, b);
    if (aHasSame ^ bHasSame) {
      // Foods with the same irritants in them are more similar than those with extra or missing
      return aHasSame ? -1 : 1;
    } else if (aHasSame && bHasSame) {
      // If irritant list is the same, compare doses of all
      var aMoreSimilar = 0.0;
      for (var refIrritant in ref.irritants) {
        final aIrritant = a.irritants.firstWhere((p0) => p0.name == refIrritant.name);
        final bIrritant = b.irritants.firstWhere((p0) => p0.name == refIrritant.name);

        // differing dose of a makes b more similar, and vice versa
        aMoreSimilar -= abs(log(aIrritant.dosePerServing) - log(refIrritant.dosePerServing));
        aMoreSimilar += abs(log(bIrritant.dosePerServing) - log(refIrritant.dosePerServing));
      }

      if (aMoreSimilar == 0) return 0;
      return aMoreSimilar > 0 ? -1 : 1;
    } else {
      // If there are extra or missing irritants, compare number of different irritants
      return _diffCount(ref, a) - _diffCount(ref, b);
    }
  }
}

ElementaryFood _removeZeroConcentration(ElementaryFood f) {
  return f.rebuild((p0) => p0.irritants = p0.irritants..removeWhere((i) => i.dosePerServing == 0));
}

/// The number of different irritants between the two objects
int _diffCount(ElementaryFood a, ElementaryFood b) {
  final aNames = a.irritants.map((p0) => p0.name).toSet();
  final bNames = b.irritants.map((p0) => p0.name).toSet();
  final abDiff = aNames.difference(bNames);
  final baDiff = bNames.difference(aNames);
  final diff = abDiff.union(baDiff);
  return diff.length;
}

bool _hasSameIrritants(ElementaryFood a, ElementaryFood b) => _diffCount(a, b) == 0;

class IrritantServiceException implements Exception {
  final String message;

  IrritantServiceException({required this.message});
}
