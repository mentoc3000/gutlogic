import 'dart:async';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food/custom_food.dart';
import '../../models/food_reference/custom_food_reference.dart';
import '../../models/serializers.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'food_repository.dart';

class CustomFoodRepository with FirestoreRepository implements FoodRepository {
  CustomFoodRepository({@required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  CustomFood _documentSnapshotToCustomFood(DocumentSnapshot documentSnapshot) => serializers.deserializeWith(
        CustomFood.serializer,
        FirestoreService.getDocumentData(documentSnapshot),
      );

  bool _foodMatchesQuery(CustomFood food, String query) => food.queryText().toLowerCase().contains(query.toLowerCase());

  Iterable<CustomFood> _documentSnapshotToResults(Iterable<DocumentSnapshot> documentSnapshots, String query) =>
      documentSnapshots.map(_documentSnapshotToCustomFood).where((food) => _foodMatchesQuery(food, query)).toList()
        ..sort((a, b) => a.queryText().compareTo(b.queryText()));

  @override
  Future<BuiltList<CustomFood>> fetchQuery(String query) async {
    if (query.isEmpty) return <CustomFood>[].build();
    final querySnapshot = await firestoreService.customFoodCollection.get();
    return BuiltList<CustomFood>(_documentSnapshotToResults(querySnapshot.docs, query));
  }

  Future<CustomFood> fetchItem(CustomFoodReference foodReference) async {
    final id = foodReference.id;
    final documentSnapshot = await firestoreService.customFoodCollection.doc(id).get();
    return _documentSnapshotToCustomFood(documentSnapshot);
  }

  @override
  Stream<BuiltList<CustomFood>> streamQuery(String query) {
    final stream = firestoreService.customFoodCollection.snapshots();
    return stream.map((querySnapshot) => BuiltList<CustomFood>(_documentSnapshotToResults(querySnapshot.docs, query)));
  }

  Stream<CustomFood> streamItem(CustomFoodReference foodReference) {
    final id = foodReference.id;
    final stream = firestoreService.customFoodCollection.doc(id).snapshots();
    return stream.map(_documentSnapshotToCustomFood);
  }

  Future<CustomFood> add({@required String name}) async {
    if (name == '') return null;

    // If a food with a case-insensitive matching name already exists, use that.
    final matches = await fetchQuery(name);
    if (matches.map((food) => food.name.toLowerCase()).contains(name.toLowerCase())) {
      return matches.firstWhere((food) => food.name.toLowerCase() == name.toLowerCase());
    }

    final food = CustomFood(id: '', name: name);
    final Map<String, dynamic> serializedFood = serializers.serialize(food);
    serializedFood.remove('id');
    final doc = await firestoreService.customFoodCollection.addUnawaited(serializedFood).get();
    return serializers.deserialize(FirestoreService.getDocumentData(doc));
  }

  Future<void> delete(CustomFood food) => deleteById(food.id);

  Future<void> deleteById(String id) => firestoreService.customFoodCollection.doc(id).delete();
}
