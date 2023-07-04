import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/models/food/ingredient.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/elementary_food.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/preferences/preferences.dart';
import 'package:gutlogic/resources/cached_api_service.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/resources/preferences_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rxdart/rxdart.dart';

import 'irritant_service_test.mocks.dart';

const appleFoodId = 'food_a1gb9ubb72c7snbuxr3weagwv0dd';
const apple = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Apple', 'id': appleFoodId},
  'foodIds': [appleFoodId, 'food_amhlqj0by3ozesbg96kkhar1atxt', 'food_bws9l24ba5vdl6bbn0q2gbev0sy2'],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.0, 'dosePerServing': 0.0, 'name': 'Mannitol'}
  ],
  'names': ['apple'],
};
const grapeFoodId = 'food_8enal231kdiyfao23';
const grape = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Grape', 'id': 'food_abc'},
  'foodIds': [grapeFoodId],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Sorbitol'},
    {'concentration': 0.01, 'dosePerServing': 0.9, 'name': 'Mannitol'}
  ],
  'names': ['grape'],
};
const breadFoodId = 'food_0afsnesa89dy9u';
const bread = {
  'canonical': {'\$': 'EdamamFoodReference', 'name': 'Grape', 'id': 'food_abcde'},
  'foodIds': [breadFoodId],
  'irritants': [
    {'concentration': 0.012, 'dosePerServing': 1.98, 'name': 'Fructan'},
  ],
  'names': ['bread'],
};
const mannitol = {
  'name': 'Mannitol',
  'intensitySteps': [0.4, 0.5, 1.0],
};
const sorbitol = {
  'name': 'Sorbitol',
  'intensitySteps': [0.1, 0.2, 0.3],
};

@GenerateMocks([CachedApiService, PreferencesService])
void main() {
  group('IrritantService', () {
    late IrritantService repository;
    late MockCachedApiService apiService;
    late MockPreferencesService preferencesService;

    setUp(() async {
      apiService = MockCachedApiService();
      preferencesService = MockPreferencesService();
      when(preferencesService.stream).thenAnswer((_) {
        return BehaviorSubject<Preferences>()..add(Preferences(irritantsExcluded: BuiltSet({'Mannitol'})));
      });
      when(apiService.get(path: '/irritant/elementaryFoods')).thenAnswer((_) {
        return Future.value({
          'data': [apple, grape, bread]
        });
      });
      when(apiService.get(path: '/irritant/intensityThresholds')).thenAnswer((_) {
        return Future.value({
          'data': [mannitol, sorbitol]
        });
      });
      repository = IrritantService(cachedApiService: apiService, preferencesService: preferencesService);
    });

    group('get irritant', () {
      test('fetches irritants by food reference', () async {
        final food = EdamamFoodReference(id: appleFoodId, name: 'apple');
        final irritants = await repository.ofRef(food);
        expect(irritants!.length, 2);
        expect(irritants.first.concentration, 0.012);
      });

      test('handles food without irritant data', () async {
        final food = EdamamFoodReference(id: 'no-info', name: 'banana');
        final irritants = await repository.ofRef(food);
        expect(irritants, null);
      });

      test('excludes irritant', () async {
        final food = EdamamFoodReference(id: appleFoodId, name: 'apple');
        final irritants = await repository.ofRef(food, usePreferences: true);
        expect(irritants!.length, 1);
        expect(irritants.first.name, 'Sorbitol');
      });
    });

    group('get intensity of food ref', () {
      test('gets threshold', () async {
        final irritant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irritant.name);
        final thresholds = [0.4, 0.5, 1.0];
        expect(intensity, thresholds);
      });

      test('no intensity from unknown irritant', () async {
        final irriant = Irritant(name: 'Salt', concentration: 0.003, dosePerServing: 0.9);
        final intensity = await repository.intensityThresholds(irriant.name);
        expect(intensity, null);
      });

      test('caches intensity thresholds', () async {
        final irriant = Irritant(name: 'Mannitol', concentration: 0.003, dosePerServing: 0.45);
        final intensity = await repository.intensityThresholds(irriant.name);
        final thresholds = [0.4, 0.5, 1.0];
        expect(intensity, thresholds);

        // API Service becomes unavailable
        when(apiService.get(path: anyNamed('path'))).thenThrow(Error());

        // IrritantService should use cached steps
        final intensity2 = await repository.intensityThresholds(irriant.name);
        expect(intensity2, thresholds);
      });
    });

    group('gets maximum intensity', () {
      test('with no preferences', () async {
        expect(await repository.maxIntensity({'Mannitol': 0.0}.build()), Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.001}.build()), Intensity.trace);
        expect(await repository.maxIntensity({'Mannitol': 2.0}.build()), Intensity.high);
        expect(await repository.maxIntensity({'Mannitol': 0.0, 'Sorbitol': 0.0}.build()), Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 0.0}.build()), Intensity.medium);
        expect(await repository.maxIntensity({'Mannitol': 0.0, 'Sorbitol': 0.15}.build()), Intensity.low);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 0.15}.build()), Intensity.medium);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 1.0}.build()), Intensity.high);
      });

      test('with preferences', () async {
        expect(await repository.maxIntensity({'Mannitol': 0.0}.build(), usePreferences: true), Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.001}.build(), usePreferences: true), Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 2.0}.build(), usePreferences: true), Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.0, 'Sorbitol': 0.0}.build(), usePreferences: true),
            Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 0.0}.build(), usePreferences: true),
            Intensity.none);
        expect(await repository.maxIntensity({'Mannitol': 0.0, 'Sorbitol': 0.15}.build(), usePreferences: true),
            Intensity.low);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 0.15}.build(), usePreferences: true),
            Intensity.low);
        expect(await repository.maxIntensity({'Mannitol': 0.7, 'Sorbitol': 1.0}.build(), usePreferences: true),
            Intensity.high);
      });
    });

    group('get irritants of ingredients', () {
      test('for ingredient that is a food', () async {
        final foodRef = EdamamFoodReference(id: appleFoodId, name: 'Apple');
        final ingredient = Ingredient(
          name: 'Apple',
          foodReference: foodRef,
        );
        final foodIntensity = await repository.ofRef(foodRef);
        final irritants = await repository.ofIngredients([ingredient]);
        expect(irritants, foodIntensity);
      });

      test('for ingredient that has ingredients', () async {
        final foodRef = EdamamFoodReference(id: appleFoodId, name: 'Apple');
        final ingredient = Ingredient(
            name: 'Baked Apple',
            ingredients: [
              Ingredient(name: 'Apple', foodReference: foodRef),
              Ingredient(name: 'Sugar'),
            ].toBuiltList());
        final foodIntensity = await repository.ofRef(foodRef);
        final irritants = await repository.ofIngredients([ingredient]);
        expect(irritants, foodIntensity);
      });

      test('for simple ingredient list', () async {
        final appleRef = EdamamFoodReference(id: appleFoodId, name: 'Apple');
        final grapeRef = EdamamFoodReference(id: grapeFoodId, name: 'Grape');
        final breadRef = EdamamFoodReference(id: breadFoodId, name: 'Bread');

        final ingredients = [
          Ingredient(name: 'Apple', foodReference: appleRef),
          Ingredient(name: 'Grape', foodReference: grapeRef),
          Ingredient(name: 'Bread', foodReference: breadRef),
        ].toBuiltList();

        final irritants = await repository.ofIngredients(ingredients);
        final expected = BuiltList<Irritant>([
          Irritant(name: 'Sorbitol', concentration: 0.012, dosePerServing: 1.98),
          Irritant(name: 'Mannitol', concentration: 0.01, dosePerServing: 0.9),
          Irritant(name: 'Fructan', concentration: 0.012, dosePerServing: 1.98),
        ]);

        expect(irritants, expected);
      });

      test('with preferences', () async {
        final appleRef = EdamamFoodReference(id: appleFoodId, name: 'Apple');
        final grapeRef = EdamamFoodReference(id: grapeFoodId, name: 'Grape');
        final breadRef = EdamamFoodReference(id: breadFoodId, name: 'Bread');

        final ingredients = [
          Ingredient(name: 'Apple', foodReference: appleRef),
          Ingredient(name: 'Grape', foodReference: grapeRef),
          Ingredient(name: 'Bread', foodReference: breadRef),
        ].toBuiltList();

        final irritants = await repository.ofIngredients(ingredients, usePreferences: true);
        final expected = BuiltList<Irritant>([
          Irritant(name: 'Sorbitol', concentration: 0.012, dosePerServing: 1.98),
          Irritant(name: 'Fructan', concentration: 0.012, dosePerServing: 1.98),
        ]);

        expect(irritants, expected);
      });

      test('for nested ingredient list', () async {
        final foodRef = EdamamFoodReference(id: appleFoodId, name: 'Apple');
        final ingredients = [
          Ingredient(
            name: 'Baked Apple',
            ingredients: [
              Ingredient(name: 'Apple', foodReference: foodRef),
              Ingredient(name: 'Sugar'),
            ].toBuiltList(),
          ),
          Ingredient(name: 'Raw Apple', foodReference: foodRef),
          Ingredient(name: 'Sugar'),
        ].toBuiltList();
        final foodIntensity = await repository.ofRef(foodRef);
        final irritants = await repository.ofIngredients(ingredients);
        expect(irritants![0].concentration, foodIntensity![0].concentration);
      });
    });

    group('similarity', () {
      final names = BuiltList<String>();
      final foodIds = BuiltList<String>();
      const EdamamFoodReference? cannonical = null;
      test('gets list of similar foods', () async {
        final fuji = EdamamFoodReference(id: appleFoodId, name: 'Fuji');
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
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((a) => a);
        final b = ref.rebuild((b) => b);

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('missing irritants are less similar than identical', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b);
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are less similar than lower dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.05));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are less similar than higher dose', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('missing irritants are valued the same', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants = b.irritants..removeAt(0));
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeAt(1));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('zero dose is the same as no data', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.0),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b);
        final b = ref.rebuild((b) => b.irritants = b.irritants..removeLast());

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('extra irritants are less similar than identical', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 0.5),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

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
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

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
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

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
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

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
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final extraIrritant = Irritant(name: 'Fructose', concentration: 0.03, dosePerServing: 1.0);
        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));
        final b = ref.rebuild((b) => b.irritants = b.irritants..add(extraIrritant));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('closer dose is more similar than further', () {
        final refIrritants = [Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 0.1)].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.09));
        final b = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = 0.2));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });

      test('dose similarity cutoff is logarithmic', () {
        final refIrritants = [Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 1.0)].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(1.0)));
        final b = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(-1.0)));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), 0);
      });

      test('multiple irritants with different doses', () {
        final refIrritants = [
          Irritant(name: 'Mannitol', concentration: 0.001, dosePerServing: 1.0),
          Irritant(name: 'Sorbitol', concentration: 0.005, dosePerServing: 1.0),
        ].toBuiltList();
        final ref = ElementaryFood(names: names, foodIds: foodIds, irritants: refIrritants, canonical: cannonical);

        final a = ref.rebuild((b) => b.irritants[0] = b.irritants[0].rebuild((p0) => p0.dosePerServing = exp(1.0)));
        final b = ref.rebuild((b) => b.irritants[1] = b.irritants[1].rebuild((p0) => p0.dosePerServing = exp(-1.1)));

        expect(IrritantService.irritantSimilarityCompare(ref, a, b), lessThan(0));
      });
    });

    group('elementary foods', () {
      test('gets elementary food', () async {
        final food = await repository.getElementaryFood(appleFoodId);
        expect(food!.names.first, 'apple');
      });

      test('returns null for not found', () async {
        final food = await repository.getElementaryFood('not-found');
        expect(food, null);
      });
    });
  });
}
