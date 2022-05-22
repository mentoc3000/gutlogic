import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/irritant_service.dart';

const foodId = 'food_a1gb9ubb72c7snbuxr3weagwv0dd';
const apple = {
  'foodIds': [foodId, 'food_amhlqj0by3ozesbg96kkhar1atxt', 'food_bws9l24ba5vdl6bbn0q2gbev0sy2'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.0, 'dosePerServing': 0.0, 'name': 'Mannitol'}
  ],
  'names': ['apple'],
};
const mannitol = {
  'name': 'mannitol',
  'intensitySteps': [0.4, 0.5, 1.0],
};

void main() {
  group('IrritantService', () {
    late FakeFirebaseFirestore firestore;
    late IrritantService repository;

    group('get irritant', () {
      const collectionPath = 'food_irritants';

      setUp(() async {
        firestore = FakeFirebaseFirestore();
        repository = IrritantService(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));
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

    group('get intensity', () {
      setUp(() async {
        firestore = FakeFirebaseFirestore();
        repository = IrritantService(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));
        await firestore.doc('irritant_data/mannitol').set(mannitol);
      });

      test('gets threshold', () async {
        final irriant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irriant);
        final thresholds = [0.0, 0.4, 0.5, 1.0];
        expect(intensity, thresholds);
      });

      test('no intensity from unknown irritant', () async {
        final irriant = Irritant(name: 'Sorbitol', concentration: 0.003, dosePerServing: 0.9);
        final intensity = await repository.intensityThresholds(irriant);
        expect(intensity, null);
      });

      test('caches intensity thresholds', () async {
        final irriant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irriant);
        final thresholds = [0.0, 0.4, 0.5, 1.0];
        expect(intensity, thresholds);

        const mannitolModified = {
          'name': 'mannitol',
          'intensitySteps': [0.1, 0.2, 0.3],
        };
        await firestore.doc('food_irritant_data/mannitol').set(mannitolModified);

        // IrritantService should use cached steps instead of new ones
        final intensity2 = await repository.intensityThresholds(irriant);
        expect(intensity2, thresholds);
      });
    });
  });
}
