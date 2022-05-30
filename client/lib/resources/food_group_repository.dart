import 'package:built_collection/built_collection.dart';

import '../models/food_group_entry.dart';
import '../models/serializers.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';

typedef FoodGroups = BuiltMap<String, BuiltList<FoodGroupEntry>>;

class FoodGroupsRepository with FirestoreRepository {
  FoodGroupsRepository({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  Future<BuiltSet<String>> groups() async {
    final foodGroupEntries = await firestoreService.foodGroupsCollection.get().then(deserialize);
    return foodGroupEntries.map((e) => e.group).toBuiltSet();
  }

  Future<BuiltSet<FoodGroupEntry>> foods({required String group}) async {
    final foodGroupEntries =
        await firestoreService.foodGroupsCollection.where('group', isEqualTo: group).get().then(deserialize);
    return foodGroupEntries.toBuiltSet();
  }

  static BuiltList<FoodGroupEntry> deserialize(UntypedQuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return BuiltList<FoodGroupEntry>();
    return snapshot.docs
        .map((s) => serializers.deserializeWith(FoodGroupEntry.serializer, s.data()) as FoodGroupEntry)
        .toBuiltList();
  }
}
