import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:gutlogic/resources/food/food_service.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'meal_element_bloc_test.mocks.dart';

@GenerateMocks([MealElementRepository, FoodService, IrritantService])
void main() {
  group('MealElementBloc', () {
    late MockMealElementRepository mealElementRepository;
    late MockFoodService foodService;
    late MockIrritantService irritantService;

    final measure = Measure(unit: 'block');
    final edamamFood = EdamamFood(
      id: '123',
      name: 'silken tofu',
      measures: [measure].build(),
    );
    final edamamFoodReference = edamamFood.toFoodReference();
    final edamamFoodMealElement = MealElement(
      id: '2',
      foodReference: edamamFoodReference,
      quantity: Quantity(amount: 1, measure: measure),
    );

    final irritants = [Irritant(name: 'GOS', concentration: 0.002, dosePerServing: 0.2)].toBuiltList();

    final quantitylessMealElement = MealElement(id: '7', foodReference: edamamFoodReference);

    final customFood = CustomFood(id: '123', name: 'Arugula');
    final customFoodMealElement = MealElement(id: '3', foodReference: customFood.toFoodReference());

    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      mealElementRepository = MockMealElementRepository();
      when(mealElementRepository.stream(edamamFoodMealElement)).thenAnswer((_) => Stream.value(edamamFoodMealElement));
      when(mealElementRepository.stream(customFoodMealElement)).thenAnswer((_) => Stream.value(customFoodMealElement));

      foodService = MockFoodService();
      when(foodService.streamFood(edamamFoodReference)).thenAnswer((_) => Stream.value(edamamFood));

      irritantService = MockIrritantService();
      when(irritantService.ofRef(any)).thenAnswer((_) => Future.value());
      when(irritantService.ofRef(edamamFoodReference)).thenAnswer((_) => Future.value(irritants));
    });

    test('initial state', () {
      final bloc = MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      );
      expect(bloc.state, MealElementLoading());
    });

    blocTest<MealElementBloc, MealElementState>(
      'streams mealElement with Edamam food',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async => bloc.add(StreamMealElement(edamamFoodMealElement)),
      expect: () => [
        MealElementLoading(),
        MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood, irritants: irritants),
      ],
      verify: (bloc) async {
        verify(mealElementRepository.stream(edamamFoodMealElement)).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'updates mealElement with Edamam food with no quantity',
      build: () {
        final newMealElement = quantitylessMealElement.rebuild((b) => b..quantity.measure = measure.toBuilder());
        when(mealElementRepository.stream(quantitylessMealElement))
            .thenAnswer((_) => Stream<MealElement>.fromIterable([newMealElement]));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(quantitylessMealElement)),
      expect: () => [
        MealElementLoading(),
        MealElementLoaded(
          mealElement: quantitylessMealElement.rebuild((b) => b..quantity.measure = measure.toBuilder()),
          food: edamamFood,
          irritants: irritants,
        ),
      ],
    );

    blocTest<MealElementBloc, MealElementState>(
      'streams mealElement with Edamam food with no measures',
      build: () {
        when(foodService.streamFood(edamamFoodReference))
            .thenAnswer((_) => Stream.value(edamamFood.rebuild((b) => b..measures = null)));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(edamamFoodMealElement)),
      expect: () => [
        MealElementLoading(),
        MealElementLoaded(
          mealElement: edamamFoodMealElement,
          food: edamamFood.rebuild((b) => b.measures = <Measure>[].build().toBuilder()),
          irritants: irritants,
        )
      ],
    );

    blocTest<MealElementBloc, MealElementState>(
      'streams mealElement with custom food',
      build: () {
        when(mealElementRepository.stream(customFoodMealElement))
            .thenAnswer((_) => Stream<MealElement>.fromIterable([customFoodMealElement]));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(customFoodMealElement)),
      expect: () => [MealElementLoaded(mealElement: customFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.stream(customFoodMealElement)).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'does not debounce streaming',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc.add(StreamMealElement(edamamFoodMealElement));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(StreamMealElement(edamamFoodMealElement));
      },
      expect: () => [
        MealElementLoading(),
        MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood, irritants: irritants),
        MealElementLoading(),
        MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood, irritants: irritants),
      ],
      verify: (bloc) async {
        verify(mealElementRepository.stream(edamamFoodMealElement)).called(2);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'loads mealElement',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async => bloc.add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null)),
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(edamamFoodMealElement));
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'does not debounce loading',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(Load(mealElement: edamamFoodMealElement.rebuild((b) => b.notes = 'asdf'), food: null, irritants: null));
      },
      expect: () => [
        MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null),
        MealElementLoaded(
            mealElement: edamamFoodMealElement.rebuild((b) => b.notes = 'asdf'), food: null, irritants: null)
      ],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(edamamFoodMealElement));
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'deletes entry',
      build: () {
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(const Delete());
      },
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(edamamFoodMealElement)).called(1);
        // verify(analyticsService.logEvent('delete_meal_element')).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'does not debounce deletion',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(const Delete())
          ..add(const Delete());
      },
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(edamamFoodMealElement)).called(2);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'updates entry',
      build: () {
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(Update(edamamFoodMealElement));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.update(edamamFoodMealElement)).called(1);
        // verify(analyticsService.logUpdateEvent('update_meal_element')).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'debounces entry updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(Update(edamamFoodMealElement))
          ..add(Update(edamamFoodMealElement))
          ..add(Update(edamamFoodMealElement));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.update(edamamFoodMealElement)).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'updates notes',
      build: () {
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(const UpdateNotes('noted'));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(edamamFoodMealElement, any)).called(1);
        // verify(analyticsService.logUpdateEvent('update_meal_element', 'notes')).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'debounces notes updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(const UpdateNotes('noted'))
          ..add(const UpdateNotes('note'))
          ..add(const UpdateNotes('not'));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(edamamFoodMealElement, 'not')).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'updates quantity',
      build: () {
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          foodService: foodService,
          irritantService: irritantService,
        );
      },
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup')));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(edamamFoodMealElement, any)).called(1);
        // verify(analyticsService.logUpdateEvent('update_meal_element', 'quantity')).called(1);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'debounces quantity updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup')))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.2, unit: 'cup')))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.3, unit: 'cup')))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup')));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(
                edamamFoodMealElement, Quantity.unweighed(amount: 2.4, unit: 'cup')))
            .called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest<MealElementBloc, MealElementState>(
      'maps multiple debounced events',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        foodService: foodService,
        irritantService: irritantService,
      ),
      act: (bloc) async {
        bloc
          ..add(Load(mealElement: edamamFoodMealElement, food: null, irritants: null))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup')))
          ..add(const UpdateNotes('too much'))
          ..add(UpdateQuantity(Quantity.unweighed(amount: 2.0, unit: 'cup')))
          ..add(const UpdateNotes('not enough'));
      },
      wait: debounceWaitDuration,
      expect: () => [MealElementLoaded(mealElement: edamamFoodMealElement, food: null, irritants: null)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(edamamFoodMealElement, any)).called(1);
        verify(mealElementRepository.updateNotes(edamamFoodMealElement, any)).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(MealElementError(message: '') is ErrorRecorder, true);
    });
  });
}
