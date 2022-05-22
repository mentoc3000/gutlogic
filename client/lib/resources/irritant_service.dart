import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';

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
  Future<BuiltList<double>?> intensityThresholds(Irritant irritant) async {
    // Get steps from cache, if available
    late final BuiltList<double>? thresholds;
    if (_intensityThresholdCache.containsKey(irritant.name)) {
      thresholds = _intensityThresholdCache[irritant.name];
    } else {
      final irritantDataDoc =
          await firestoreService.irritantDataCollection.where('name', isEqualTo: irritant.name.toLowerCase()).get();

      // Return null if irritant can't be found
      if (irritantDataDoc.docs.isEmpty) {
        thresholds = null;
      } else {
        final irritantData =
            serializers.deserializeWith(FoodIrritantDataApi.serializer, irritantDataDoc.docs.first.data());
        thresholds = [0.0, ...?irritantData?.intensitySteps].toBuiltList();
      }

      _intensityThresholdCache[irritant.name] = thresholds;
    }

    return thresholds;
  }

  Future<int?> maxIntensity(Iterable<Irritant>? irritants) async {
    if (irritants == null) return null;

    var maxIntensity = 0;
    for (var irritant in irritants) {
      final thresholds = await intensityThresholds(irritant);
      if (thresholds == null) continue;
      final intensity = thresholds.map((t) => irritant.dosePerServing > t).fold<int>(0, (acc, tf) => acc += tf ? 1 : 0);
      if (intensity > maxIntensity) {
        maxIntensity = max(maxIntensity, intensity);
      }
    }
    return maxIntensity;
  }
}
