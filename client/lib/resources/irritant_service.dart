import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../models/food_reference/food_reference.dart';
import '../models/irritant/food_irritant_data_api.dart';
import '../models/irritant/food_irritants_api.dart';
import '../models/irritant/irritant.dart';
import '../models/serializers.dart';
import '../util/math.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';

class IrritantService with FirestoreRepository {
  final Map<String, BuiltList<double>?> _intensityThresholdCache = {};

  IrritantService({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  Future<BuiltList<Irritant>?> ofRef(FoodReference food) {
    return firestoreService.irritantCollection
        .where('foodIds', arrayContains: food.id)
        .get()
        .then(deserialize)
        .then((value) => value.firstWhere((element) => element != null, orElse: () => null)?.irritants);
  }

  Future<BuiltList<Irritant>?> ofName(String name) {
    return firestoreService.irritantCollection
        .where('names', arrayContains: name)
        .get()
        .then(deserialize)
        .then((value) => value.firstWhere((element) => element != null)?.irritants);
  }

  static Iterable<FoodIrritantsApi?> deserialize(UntypedQuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => serializers.deserializeWith(FoodIrritantsApi.serializer, doc.data()) as FoodIrritantsApi);
  }

  Future<BuiltSet<String>> names() async {
    final snapshot = await firestoreService.irritantDataCollection.get();
    return snapshot.docs
        .map((doc) => serializers.deserializeWith(FoodIrritantDataApi.serializer, doc.data()))
        .whereType<FoodIrritantDataApi>()
        .map((i) => i.name)
        .toBuiltSet();
  }

  /// Dose thresholds at which the intensity increases
  Future<BuiltList<double>?> intensityThresholds(String irritant) async {
    // Get steps from cache, if available
    late final BuiltList<double>? thresholds;
    if (_intensityThresholdCache.containsKey(irritant)) {
      thresholds = _intensityThresholdCache[irritant];
    } else {
      final irritantDataDoc = await firestoreService.irritantDataCollection.where('name', isEqualTo: irritant).get();

      // Return null if irritant can't be found
      if (irritantDataDoc.docs.isEmpty) {
        thresholds = null;
      } else {
        thresholds = serializers
            .deserializeWith(FoodIrritantDataApi.serializer, irritantDataDoc.docs.first.data())
            ?.intensitySteps
            .toBuiltList();
      }

      _intensityThresholdCache[irritant] = thresholds;
    }

    return thresholds;
  }

  Future<int> maxIntensity(BuiltMap<String, double> doses) async {
    var maxIntensity = 0;
    for (var doseEntry in doses.entries) {
      final irritantName = doseEntry.key;
      final dose = doseEntry.value;
      final thresholds = await intensityThresholds(irritantName);
      if (thresholds == null) continue;
      final intensity = thresholds.map((t) => dose > t).fold<int>(0, (acc, tf) => acc += tf ? 1 : 0);
      if (intensity > maxIntensity) {
        maxIntensity = max(maxIntensity, intensity);
      }
    }
    return maxIntensity;
  }

  Future<BuiltList<FoodIrritantsApi>> similar(FoodReference food) async {
    final ref = await firestoreService.irritantCollection
        .where('foodIds', arrayContains: food.id)
        .get()
        .then(deserialize)
        .then((value) => value.firstWhere((element) => element != null, orElse: () => null));
    if (ref == null) return BuiltList<FoodIrritantsApi>();
    final irritantNames = ref.irritants.map((i) => i.name).toSet();

    // Get foods that contain at least one irritant that food has
    final allFoodIrritantsApi = await firestoreService.irritantCollection.get().then(deserialize);

    final foodIrritantsApi = allFoodIrritantsApi
        // Filter out nulls
        .whereType<FoodIrritantsApi>()
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
  static int irritantSimilarityCompare(FoodIrritantsApi ref, FoodIrritantsApi a, FoodIrritantsApi b) {
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

FoodIrritantsApi _removeZeroConcentration(FoodIrritantsApi f) {
  return f.rebuild((p0) => p0.irritants = p0.irritants..removeWhere((i) => i.dosePerServing == 0));
}

/// The number of different irritants between the two objects
int _diffCount(FoodIrritantsApi a, FoodIrritantsApi b) {
  final aNames = a.irritants.map((p0) => p0.name).toSet();
  final bNames = b.irritants.map((p0) => p0.name).toSet();
  final abDiff = aNames.difference(bNames);
  final baDiff = bNames.difference(aNames);
  final diff = abDiff.union(baDiff);
  return diff.length;
}

bool _hasSameIrritants(FoodIrritantsApi a, FoodIrritantsApi b) => _diffCount(a, b) == 0;
