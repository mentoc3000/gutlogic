import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/food/custom_food.dart';
import '../../models/food_reference/custom_food_reference.dart';
import '../../models/serializers.dart';
import '../../util/null_utils.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';

class CustomFoodRepository with FirestoreRepository {
  CustomFoodRepository({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  CustomFood? _documentSnapshotToCustomFood(UntypedSnapshot snapshot) {
    final documentData = FirestoreService.getDocumentData(snapshot);
    if (documentData == null) return null;
    return serializers.deserializeWith(CustomFood.serializer, documentData);
  }

  Iterable<CustomFood?> _documentSnapshotToResults(Iterable<UntypedSnapshot> snapshots, String query) {
    final customFoods = snapshots.map(_documentSnapshotToCustomFood);
    return _matchQuery(customFoods, query);
  }

  Iterable<CustomFood> _matchQuery(Iterable<CustomFood?> foods, String query) {
    final matches = foods.where((food) => food?.queryText().toLowerCase().contains(query.toLowerCase()) ?? false);
    return matches.cast<CustomFood>().toList()..sort((a, b) => a.queryText().compareTo(b.queryText()));
  }

  Stream<BuiltList<CustomFood>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<CustomFood>[].build());

    final docStream = firestoreService.customFoodCollection.snapshots();
    return docStream
        .map((querySnapshot) => _documentSnapshotToResults(querySnapshot.docs, query).whereNotNull().toBuiltList());
  }

  Stream<CustomFood> streamFood(CustomFoodReference foodReference) {
    final id = foodReference.id;
    final docStream = firestoreService.customFoodCollection.doc(id).snapshots();
    return docStream
        .map(_documentSnapshotToCustomFood)
        .map((f) => f ?? CustomFood(id: foodReference.id, name: foodReference.name));
  }

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
