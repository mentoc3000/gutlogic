import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/food_group_repository.dart';

void main() {
  group('FoodGroupsRepository', () {
    const collectionName = 'food_groups2';
    late FoodGroupsRepository repository;
    final foodGroupEntries = [
      {
        'foodRef': {'\$': 'EdamamFoodReference', 'name': 'Green Beans', 'id': 'food1'},
        'group': 'Vegetables',
        'doses': <String, double>{}
      },
      {
        'foodRef': {'\$': 'EdamamFoodReference', 'name': 'Cherry', 'id': 'food2'},
        'group': 'Fruits',
        'doses': <String, double>{},
      }
    ];

    setUp(() async {
      final firestore = FakeFirebaseFirestore();
      repository = FoodGroupsRepository(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));

      var idx = 0;
      for (Map<String, dynamic> foodGroupEntry in foodGroupEntries) {
        await firestore.doc('$collectionName/$idx').set(foodGroupEntry);
        idx++;
      }
      await Future<void>.delayed(Duration.zero);
    });

    test('groups', () async {
      final groups = await repository.groups();
      expect(groups.first, 'Vegetables');
      expect(groups.length, 2);
    });

    test('foods', () async {
      final foods = await repository.foods(group: 'Fruits');
      expect(foods.length, 1);
      expect(foods.first.foodRef.name, 'Cherry');
    });
  });
}
