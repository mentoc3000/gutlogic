import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../models/food_reference/food_reference.dart';
import '../models/irritant/food_irritants_api.dart';
import '../models/irritant/irritant.dart';
import '../models/serializers.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';

class IrritantRepository with FirestoreRepository {
  IrritantRepository({required FirestoreService firestoreService}) {
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
}
