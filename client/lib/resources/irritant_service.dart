import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';

import '../models/food_group_entry.dart';
import '../models/food_reference/food_reference.dart';
import '../models/irritant/food_irritant_data_api.dart';
import '../models/irritant/food_irritants_api.dart';
import '../models/irritant/irritant.dart';
import '../models/serializers.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';

class IrritantService with FirestoreRepository {
  final Map<String, BuiltList<double>?> _intensityThresholdCache = {};

  IrritantService({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  Future<BuiltList<Irritant>?> ofRef(FoodReference food) {
    return firestoreService.irritantCollection.where('foodIds', arrayContains: food.id).get().then(deserialize);
  }

  Future<BuiltList<Irritant>?> ofName(String name) {
    return firestoreService.irritantCollection.where('names', arrayContains: name).get().then(deserialize);
  }

  static BuiltList<Irritant>? deserialize(UntypedQuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    final foodIrritants = serializers.deserializeWith(FoodIrritantsApi.serializer, data) as FoodIrritantsApi;
    return foodIrritants.irritants;
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

  Future<int> maxIntensity(FoodGroupEntry foodGroupEntry) async {
    var maxIntensity = 0;
    for (var doseEntry in foodGroupEntry.doses.entries) {
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
}
