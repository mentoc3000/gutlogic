import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/food_group_repository.dart';

void main() {
  group('FoodGroupsRepository', () {
    const collectionName = 'food_groups';
    final foodGroup = {
      'name': 'Vegetables',
      'foodRefs': [
        {'\$': 'EdamamFoodReference', 'name': 'Green Beans', 'id': 'food1'},
        {'\$': 'EdamamFoodReference', 'name': 'Lettuce', 'id': 'food2'},
      ]
    };

    test('description', () async {
      final firestore = FakeFirebaseFirestore();
      final repository =
          FoodGroupsRepository(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));

      await firestore.doc('$collectionName/123').set(foodGroup);
      await Future.delayed(Duration.zero);

      final groups = await repository.all();
      await expectLater(groups.first.name, 'Vegetables');
    });
  });
}
