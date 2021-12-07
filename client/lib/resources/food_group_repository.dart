import '../models/food_group.dart';
import '../models/serializers.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';

class FoodGroupsRepository with FirestoreRepository {
  FoodGroupsRepository({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  // TODO: change Iterable to List
  Future<Iterable<FoodGroup>> all() async {
    return firestoreService.foodGroupsCollection.get().then(deserialize);
  }

  static Iterable<FoodGroup> deserialize(UntypedQuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return <FoodGroup>[];
    return snapshot.docs.map((s) => serializers.deserializeWith(FoodGroup.serializer, s.data()) as FoodGroup);
  }
}
