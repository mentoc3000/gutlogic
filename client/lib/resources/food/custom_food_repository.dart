import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/food/custom_food.dart';
import '../../models/food_reference/custom_food_reference.dart';
import '../../models/serializers.dart';
import '../../util/null_utils.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import '../pantry_repository.dart';
import 'food_repository.dart';

class CustomFoodRepository with FirestoreRepository, FoodRepository<CustomFood> {
  CustomFoodRepository({required FirestoreService firestoreService, required PantryRepository pantryRepository}) {
    this.firestoreService = firestoreService;
    this.pantryRepository = pantryRepository;
  }

  Future<CustomFood?> _documentSnapshotToCustomFood(DocumentSnapshot documentSnapshot) async {
    return serializers.deserializeWith(
      CustomFood.serializer,
      FirestoreService.getDocumentData(documentSnapshot),
    );
  }

  Future<Iterable<CustomFood?>> _documentSnapshotToResults(
      Iterable<DocumentSnapshot> documentSnapshots, String query) async {
    final customFoods = await Future.wait(documentSnapshots.map(_documentSnapshotToCustomFood));
    return _matchQuery(customFoods, query);
  }

  Iterable<CustomFood> _matchQuery(Iterable<CustomFood?> foods, String query) {
    final matches = foods.where((food) => food?.queryText().toLowerCase().contains(query.toLowerCase()) ?? false);
    return matches.cast<CustomFood>().toList()..sort((a, b) => a.queryText().compareTo(b.queryText()));
  }

  @override
  Stream<BuiltList<CustomFood>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<CustomFood>[].build());

    final docStream = firestoreService.customFoodCollection.snapshots();
    final foodStream = docStream.asyncMap((querySnapshot) => _documentSnapshotToResults(querySnapshot.docs, query));
    final maybeFoodWithPantryEntry =
        mergePantryEntryStreams(pantryRepository: pantryRepository, foodStream: foodStream);
    return maybeFoodWithPantryEntry.map((foods) => foods.whereNotNull().toBuiltList());
  }

  Stream<CustomFood?> streamFood(CustomFoodReference foodReference) {
    final id = foodReference.id;
    final docStream = firestoreService.customFoodCollection.doc(id).snapshots();
    final foodStream = docStream.asyncMap(_documentSnapshotToCustomFood);
    return mergePantryEntryStream(pantryRepository: pantryRepository, foodStream: foodStream);
  }

  @override
  Future<BuiltList<CustomFood>> fetchQuery(String query) => streamQuery(query).first;

  Future<CustomFood?> fetchFood(CustomFoodReference foodReference) => streamFood(foodReference).first;

  Future<void> delete(CustomFood food) => deleteById(food.id);

  Future<void> deleteById(String id) => firestoreService.customFoodCollection.doc(id).delete();

  Future<CustomFood?> add({required String name}) async {
    if (name == '') return null;

    // If a food with a case-insensitive matching name already exists, use that.
    final matches = await fetchQuery(name);
    if (matches.map((food) => food.name.toLowerCase()).contains(name.toLowerCase())) {
      return matches.firstWhere((food) => food.name.toLowerCase() == name.toLowerCase());
    }

    final food = CustomFood(id: '', name: name);
    final serializedFood = serializers.serialize(food) as Map<String, dynamic>?;
    if (serializedFood == null) return null;
    serializedFood.remove('id');
    final doc = await firestoreService.customFoodCollection.addUnawaited(serializedFood).get();
    return serializers.deserialize(FirestoreService.getDocumentData(doc)) as CustomFood?;
  }
}
