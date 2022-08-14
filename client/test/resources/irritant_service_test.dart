import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/food_irritants_api.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/irritant_service.dart';

const foodId = 'food_a1gb9ubb72c7snbuxr3weagwv0dd';
const apple = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Apple', 'id': foodId},
  'foodIds': [foodId, 'food_amhlqj0by3ozesbg96kkhar1atxt', 'food_bws9l24ba5vdl6bbn0q2gbev0sy2'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.0, 'dosePerServing': 0.0, 'name': 'Mannitol'}
  ],
  'names': ['apple'],
};
const grape = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Grape', 'id': 'food_abc'},
  'foodIds': ['food_abc'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.01, 'dosePerServing': 0.9, 'name': 'Mannitol'}
  ],
  'names': ['grape'],
};
const bread = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Grape', 'id': 'food_abcde'},
  'foodIds': ['food_abcde'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Fructan'},
  ],
  'names': ['bread'],
};
const mannitol = {
  'name': 'Mannitol',
  'intensitySteps': [0.0, 0.4, 0.5, 1.0],
};

void main() {
  group('IrritantService', () {
    late FakeFirebaseFirestore firestore;
    late IrritantService repository;
    const collectionPath = 'food_irritants';

    group('get irritant', () {
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
        final irritant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irritant.name);
        final thresholds = [0.0, 0.4, 0.5, 1.0];
        expect(intensity, thresholds);
      });

      test('no intensity from unknown irritant', () async {
        final irriant = Irritant(name: 'Sorbitol', concentration: 0.003, dosePerServing: 0.9);
        final intensity = await repository.intensityThresholds(irriant.name);
        expect(intensity, null);
      });

      test('caches intensity thresholds', () async {
        final irriant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irriant.name);
        final thresholds = [0.0, 0.4, 0.5, 1.0];
        expect(intensity, thresholds);

        const mannitolModified = {
          'name': 'mannitol',
          'intensitySteps': [0.0, 0.1, 0.2, 0.3],
        };
        await firestore.doc('food_irritant_data/mannitol').set(mannitolModified);

        // IrritantService should use cached steps instead of new ones
        final intensity2 = await repository.intensityThresholds(irriant.name);
        expect(intensity2, thresholds);
      });
    });

    group('similarity', () {
      final names = BuiltList<String>();
      final foodIds = BuiltList<String>();
      const EdamamFoodReference? cannonical = null;

      setUp(() async {
        firestore = FakeFirebaseFirestore();
        repository = IrritantService(firestoreService: FirestoreService(userID: 'testUID', instance: firestore));
        await firestore.doc('$collectionPath/12').set(bread);
        await firestore.doc('$collectionPath/1234').set(apple);
        await firestore.doc('$collectionPath/123').set(grape);
      });

      test('gets list of similar foods', () async {
        final fuji = EdamamFoodReference(id: foodId, name: 'Fuji');
        final similars = await repository.similar(fuji);
        expect(similars.length, 2);
        expect(similars.first.canonical!.name, 'Apple');
        expect(similars.last.canonical!.name, 'Grape');
      });

      test('equality', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((a) => a);
        final b = ref.rebuild((b) => b);

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('missing irritants are less similar than identical', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b);
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are less similar than lower dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.05));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are less similar than higher dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are valued the same', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants = b.irritants..removeAt(0));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeAt(1));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('zero dose is the same as no data', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.0),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b);
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('extra irritants are less similar than identical', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b);
        final b = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('extra irritants are valued the same', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));
        final b =
            ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant.rebuild((p0) => p0.dosePerServing = 1.1)));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('extra irritants are comparable to missing irritants', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('extra irritants are less similar than lower dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.05));
        final b = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('extra irritants are less similar than higher dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));
        final b = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('closer dose is more similar than further', () {
        final refIrritants = [Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1)].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.09));
        final b = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('dose similarity cutoff is logarithmic', () {
        final refIrritants = [Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 1.0)].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(1.0)));
        final b = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(-1.0)));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('multiple irritants with different doses', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 1.0),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 1.0),
        ].toBuiltList();
        final ref = FoodIrritantsApi(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(1.0)));
        final b = ref.rebuild((b) => b.irritants[1] = b.irritants[1].rebuild((p0) => p0.dosePerServing = exp(-1.1)));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });
    });
  });
}
