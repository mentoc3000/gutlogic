import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/food_reference/food_reference.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/resources/sensitivity/heuristic_sensitivity_prediction_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'heuristic_sensitivity_prediction_service_test.mocks.dart';

final unkP = Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.prediction);
final noneP = Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.prediction);
final mildP = Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.prediction);
final modP = Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.prediction);
final sevP = Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.prediction);

final unkU = Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user);
final noneU = Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user);
final mildU = Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.user);
final modU = Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user);
final sevU = Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user);

@GenerateMocks([IrritantService])
void main() {
  group('HeuristicSensitivityPredictionService', () {
    late HeuristicSensitivityPredictionService predictor;
    late MockIrritantService irritantService;
    const predictionDelay = Duration(milliseconds: 100);

    /// Perform setup prior to each test
    ///
    /// Custom setUp is required to mock repository data before instantiating [HeuristicSensitivityPredictionService].
    Future<void> customSetUp({
      required List<Sensitivity?> sensitivities,
      required List<List<double?>> concentrations,
    }) async {
      irritantService = MockIrritantService();
      when(irritantService.ofRef(any)).thenAnswer((_) => Future.value(null));

      final sensitivityLevels = sensitivities.map((s) => s?.level);
      final mockData = MockData.from(sensitivityLevels: sensitivityLevels, concentrations: concentrations);
      for (final foodAndIrritants in mockData.foodsAndIrritants.entries) {
        when(irritantService.ofRef(foodAndIrritants.key.toFoodReference()))
            .thenAnswer((_) => Future.value(foodAndIrritants.value));
      }
      final sensitivityMapStream = Stream.value(mockData.sensitivityMap);

      predictor = HeuristicSensitivityPredictionService(
        irritantService: irritantService,
        sensitivityMapStream: sensitivityMapStream,
      );
    }

    EdamamFoodReference getTestFood({required List<double> concentrations}) {
      final uniqueStr = DateTime.now().toIso8601String();
      final irritants = [
        for (int i = 0; i < concentrations.length; i += 1)
          Irritant(name: irritantName(i), concentration: concentrations[i], dosePerServing: concentrations[i])
      ].build();
      final edamamFood = EdamamFood(id: uniqueStr, name: uniqueStr);
      when(irritantService.ofRef(edamamFood.toFoodReference())).thenAnswer((_) => Future.value(irritants));
      return edamamFood.toFoodReference();
    }

    test('food without irritants has unknown sensitivity', () async {
      final sensitivities = [noneU, noneU, mildU, mildU, modU, modU, sevU, sevU];
      final concentrations = <List<double>>[];
      await customSetUp(sensitivities: sensitivities, concentrations: concentrations);

      await expectLater(predictor.predict(getTestFood(concentrations: [])), completion(unkP));

      final otherFoodRef = EdamamFoodReference(id: 'other-food', name: 'Otter Food');
      await expectLater(predictor.predict(otherFoodRef), completion(unkP));
    });

    test('predicts sensitivity of single irritant with simple, dense data', () async {
      final sensitivities = [noneU, noneU, mildU, mildU, modU, modU, sevU, sevU];
      final concentrations = [
        [0.0, 1E-5, 2E-5, 3E-5, 4E-5, 5E-5, 6E-5, 7E-5]
      ];
      await customSetUp(sensitivities: sensitivities, concentrations: concentrations);

      await expectLater(predictor.predict(getTestFood(concentrations: [0])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0.5E-5])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [2.5E-5])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [4.5E-5])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [6.5E-5])), completion(sevP));

      await expectLater(predictor.predict(getTestFood(concentrations: [0, 1E-4])), completion(unkP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0.5E-5, 1E-4])), completion(unkP));
      await expectLater(predictor.predict(getTestFood(concentrations: [2.5E-5, 1E-4])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [4.5E-5, 1E-4])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [6.5E-5, 1E-4])), completion(sevP));
    });

    test('predicts sensitivity of multiple, independent irritants', () async {
      final sensitivities = [noneU, noneU, mildU, modU, sevU, noneU, mildU, modU, sevU];
      final concentrations = [
        [0.0, 0.0, 0.0, 0.0, 0.0, 1E-5, 2E-5, 3E-5, 4E-5],
        [0.0, 1E-5, 2E-5, 3E-5, 4E-5, 0.0, 0.0, 0.0, 0.0],
      ];
      await customSetUp(sensitivities: sensitivities, concentrations: concentrations);

      await expectLater(predictor.predict(getTestFood(concentrations: [0])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0.5E-5])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [1.5E-5])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [2.5E-5])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [3.5E-5])), completion(sevP));

      await expectLater(predictor.predict(getTestFood(concentrations: [0, 0])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 0.5E-5])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 1.5E-5])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 2.5E-5])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 3.5E-5])), completion(sevP));

      await expectLater(predictor.predict(getTestFood(concentrations: [0, 0])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0.5E-5, 0])), completion(noneP));
      await expectLater(predictor.predict(getTestFood(concentrations: [1.5E-5, 0])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [2.5E-5, 0])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [3.5E-5, 0])), completion(sevP));

      await expectLater(predictor.predict(getTestFood(concentrations: [1.5E-5, 2.5E-5])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [3.5E-5, 1.5E-5])), completion(sevP));

      await expectLater(predictor.predict(getTestFood(concentrations: [0, 0, 1E-4])), completion(unkP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 0.5E-5, 1E-4])), completion(unkP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 1.5E-5, 1E-4])), completion(mildP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 2.5E-5, 1E-4])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [0, 3.5E-5, 1E-4])), completion(sevP));
    });

    test('predicts sensitivity of multiple, mixed irritants', () async {
      final sensitivities = [noneU, mildU, modU, sevU];
      final concentrations = [
        [0.0, 2E-5, 1E-5, 4E-5],
        [1E-5, 0.0, 3E-5, 2E-5]
      ];
      await customSetUp(sensitivities: sensitivities, concentrations: concentrations);

      await expectLater(predictor.predict(getTestFood(concentrations: [0.5E-5, 0.5E-5])), completion(modP));
      await expectLater(predictor.predict(getTestFood(concentrations: [2.5E-5, 2.5E-5])), completion(sevP));
      await expectLater(predictor.predict(getTestFood(concentrations: [3.5E-5, 3.5E-5])), completion(sevP));
    });

    test('added sensitivities update prediction', () async {
      irritantService = MockIrritantService();
      when(irritantService.ofRef(any)).thenAnswer((_) => Future.value(null));

      final streamController = StreamController<BuiltMap<FoodReference, Sensitivity>>();

      predictor = HeuristicSensitivityPredictionService(
        irritantService: irritantService,
        sensitivityMapStream: streamController.stream,
      );

      final sensitivities = [noneU, modU];
      final concentrations = [
        [0.0, 4E-5]
      ];
      final sensitivityLevels = sensitivities.map((s) => s.level);
      final mockData = MockData.from(sensitivityLevels: sensitivityLevels, concentrations: concentrations);
      for (final foodAndIrritants in mockData.foodsAndIrritants.entries) {
        when(irritantService.ofRef(foodAndIrritants.key.toFoodReference()))
            .thenAnswer((_) => Future.value(foodAndIrritants.value));
      }
      streamController.add(mockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [3E-5])), completion(modP));

      final updatedSensitivities = [noneU, modU, mildU];
      final updatedConcentrations = [
        [0.0, 4E-5, 3.9E-5]
      ];
      final updatedSensitivityLevels = updatedSensitivities.map((s) => s.level);
      final updatedMockData =
          MockData.from(sensitivityLevels: updatedSensitivityLevels, concentrations: updatedConcentrations);
      for (final foodAndIrritants in updatedMockData.foodsAndIrritants.entries) {
        when(irritantService.ofRef(foodAndIrritants.key.toFoodReference()))
            .thenAnswer((_) => Future.value(foodAndIrritants.value));
      }
      streamController.add(updatedMockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [3E-5])), completion(mildP));
    });

    test('removed sensitivities update prediction', () async {
      irritantService = MockIrritantService();
      when(irritantService.ofRef(any)).thenAnswer((_) => Future.value(null));

      final streamController = StreamController<BuiltMap<FoodReference, Sensitivity>>();

      predictor = HeuristicSensitivityPredictionService(
        irritantService: irritantService,
        sensitivityMapStream: streamController.stream,
      );

      final sensitivities = [noneU, modU, mildU];
      final concentrations = [
        [0.0, 4E-5, 3.9E-5]
      ];
      final sensitivityLevels = sensitivities.map((s) => s.level);
      final mockData = MockData.from(sensitivityLevels: sensitivityLevels, concentrations: concentrations);
      for (final foodAndIrritants in mockData.foodsAndIrritants.entries) {
        when(irritantService.ofRef(foodAndIrritants.key.toFoodReference()))
            .thenAnswer((_) => Future.value(foodAndIrritants.value));
      }
      streamController.add(mockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [3E-5])), completion(mildP));

      final updatedSensitivities = [noneU, modU];
      final updatedConcentrations = [
        [0.0, 4E-5]
      ];
      final updatedSensitivityLevels = updatedSensitivities.map((s) => s.level);
      final updatedMockData =
          MockData.from(sensitivityLevels: updatedSensitivityLevels, concentrations: updatedConcentrations);
      streamController.add(updatedMockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [3E-5])), completion(modP));
    });

    test('updated sensitivities update prediction', () async {
      irritantService = MockIrritantService();
      when(irritantService.ofRef(any)).thenAnswer((_) => Future.value(null));

      final streamController = StreamController<BuiltMap<FoodReference, Sensitivity>>();

      predictor = HeuristicSensitivityPredictionService(
        irritantService: irritantService,
        sensitivityMapStream: streamController.stream,
      );

      final sensitivities = [noneU, mildU, modU, sevU];
      final concentrations = [
        [0.0, 1E-5, 2E-5, 3E-5]
      ];
      final sensitivityLevels = sensitivities.map((s) => s.level);
      final mockData = MockData.from(sensitivityLevels: sensitivityLevels, concentrations: concentrations);
      for (final foodAndIrritants in mockData.foodsAndIrritants.entries) {
        when(irritantService.ofRef(foodAndIrritants.key.toFoodReference()))
            .thenAnswer((_) => Future.value(foodAndIrritants.value));
      }
      streamController.add(mockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [1.5E-5])), completion(modP));

      final updatedSensitivities = [sevU, sevU, sevU, sevU];
      final updatedSensitivityLevels = updatedSensitivities.map((s) => s.level);
      final updatedMockData =
          MockData.from(sensitivityLevels: updatedSensitivityLevels, concentrations: concentrations);
      streamController.add(updatedMockData.sensitivityMap);
      await Future.delayed(predictionDelay);
      await expectLater(predictor.predict(getTestFood(concentrations: [1.5E-5])), completion(sevP));
    });
  });
}

String irritantName(int index) => 'irr-$index';

/// A wrapper class for mocked data
class MockData {
  final Map<EdamamFood, BuiltList<Irritant>> foodsAndIrritants;
  final List<SensitivityEntry> sensitivityEntries;
  BuiltMap<FoodReference, Sensitivity> get sensitivityMap => BuiltMap.of({
        for (var s in sensitivityEntries)
          s.foodReference: Sensitivity(level: s.sensitivityLevel, source: SensitivitySource.user)
      });

  MockData._({required this.foodsAndIrritants, required this.sensitivityEntries});

  /// Construct [MockData] from lists of [SensitivityLevel]s and doses.
  ///
  /// [SensitivityEntry]s consist of an arbitrary food and the given sensitivities. [concentrations] is a nestsed list where the first
  /// index is the (arbitrary) irritant and the second index is the food it is associated with.
  ///
  /// ```dart
  /// final mockData = MockData.from(
  ///   sensitivities: [SensitivityLevel.none, SensitivityLevel.mild, SensitivityLevel.severe],
  ///   doses: [[0.0, 1.3, 2.5], [0.5, 0.0, 2.7]],
  /// );
  /// assert(mockData.edamamFoods[0] == EdamamFood(id: 'food-1', name: 'food-1', irritants:
  ///   [Irritant(name: 'irr-1', concentration: 0.0), Irritant(name: 'irr-1', concentration: 0.5)]));
  /// ```
  factory MockData.from(
      {required Iterable<SensitivityLevel?> sensitivityLevels, required List<List<double?>> concentrations}) {
    for (var c in concentrations) {
      assert(sensitivityLevels.length == c.length);
    }

    MapEntry<EdamamFood, BuiltList<Irritant>> foodFrom(int foodIndex) {
      final foodName = 'food-$foodIndex';
      final irritants = [
        for (var irrIndex = 0; irrIndex < concentrations.length; irrIndex += 1)
          Irritant(
              name: irritantName(irrIndex),
              concentration: concentrations[irrIndex][foodIndex]!,
              dosePerServing: concentrations[irrIndex][foodIndex]!)
      ].build();
      final food = EdamamFood(id: foodName, name: foodName);
      return MapEntry(food, irritants);
    }

    final foodsAndIrritantsEntries = List.generate(sensitivityLevels.length, (index) => index).map(foodFrom).toList();
    final foodsAndIrritants = Map.fromEntries(foodsAndIrritantsEntries);

    final someSensitivities = sensitivityLevels.whereType<SensitivityLevel>().toList();
    final sensitivityEntries = [
      for (int i = 0; i < someSensitivities.length; i += 1)
        SensitivityEntry(
          userFoodDetailsId: 'pe-$i',
          foodReference: foodsAndIrritantsEntries[i].key.toFoodReference(),
          sensitivityLevel: someSensitivities[i],
        )
    ];

    return MockData._(foodsAndIrritants: foodsAndIrritants, sensitivityEntries: sensitivityEntries);
  }
}
