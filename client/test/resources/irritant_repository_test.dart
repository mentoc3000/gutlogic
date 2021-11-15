import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/irritant_repository.dart';

const foodId = 'food_a1gb9ubb72c7snbuxr3weagwv0dd';
const apple = {
  'foodIds': [foodId, 'food_amhlqj0by3ozesbg96kkhar1atxt', 'food_bws9l24ba5vdl6bbn0q2gbev0sy2'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.0, 'dosePerServing': 0.0, 'name': 'Mannitol'}
  ],
  'names': ['apple'],
};

void main() {
  group('IrritantRepository', () {
    const collectionPath = 'food_irritants';
    late FakeFirebaseFirestore firestore;
    late IrritantRepository repository;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      repository = IrritantRepository(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));
      await firestore.doc('$collectionPath/1234').set(apple);
    });

    test('fetches irritants by food reference', () async {
      final food = EdamamFoodReference(id: foodId, name: 'apple');
      final irritants = await repository.ofRef(food);
      expect(irritants!.length, 2);
      expect(irritants.first.concentration, 0.012);
    });

    test('fetches irritants by name', () async {
      final irritants = await repository.ofName('apple');
      expect(irritants!.length, 2);
      expect(irritants.first.concentration, 0.012);
    });

    test('handles food without irritant data', () async {
      final food = EdamamFoodReference(id: 'no-info', name: 'banana');
      final irritants = await repository.ofRef(food);
      expect(irritants, null);
    });
  });
}
