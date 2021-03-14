import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/resources/food/edamam_food_repository.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('MealElementBloc', () {
    MealElementRepository mealElementRepository;
    EdamamFoodRepository edamamFoodRepository;
    final measure = Measure(unit: 'block');
    final edamamFood = EdamamFood(
      id: '123',
      name: 'silken tofu',
      measures: [measure].build(),
    );
    final edamamFoodMealElement = MealElement(
      id: '2',
      foodReference: edamamFood.toFoodReference(),
      quantity: Quantity(amount: 1, measure: measure),
    );
    final quantitylessMealElement = MealElement(
      id: '7',
      foodReference: edamamFood.toFoodReference(),
    );
    final customFood = CustomFood(id: '123', name: 'Arugula');
    final customFoodMealElement = MealElement(id: '3', foodReference: customFood.toFoodReference());
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      mealElementRepository = MockMealElementRepository();
      when(mealElementRepository.stream(edamamFoodMealElement))
          .thenAnswer((_) => Stream<MealElement>.fromIterable([edamamFoodMealElement]));
      edamamFoodRepository = MockEdamamFoodRepository();
      when(edamamFoodRepository.fetchItem(edamamFood.id)).thenAnswer((_) async => await edamamFood);
    });

    test('initial state', () {
      expect(
          MealElementBloc(
            mealElementRepository: mealElementRepository,
            edamamFoodRepository: edamamFoodRepository,
          ).state,
          MealElementLoading());
    });

    blocTest(
      'streams mealElement with Edamam food',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc.add(StreamMealElement(edamamFoodMealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [MealElementLoading(), MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood)],
      verify: (bloc) async {
        verify(mealElementRepository.stream(edamamFoodMealElement)).called(1);
      },
    );

    blocTest(
      'updates mealElement with Edamam food with no quantity',
      build: () {
        when(mealElementRepository.stream(quantitylessMealElement)).thenAnswer((_) => Stream<MealElement>.fromIterable([
              quantitylessMealElement.rebuild((b) => b..quantity.measure = measure.toBuilder()),
            ]));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(quantitylessMealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [
        MealElementLoading(),
        MealElementLoaded(
            mealElement: quantitylessMealElement.rebuild((b) => b..quantity.measure = measure.toBuilder()),
            food: edamamFood),
      ],
    );

    blocTest(
      'streams mealElement with Edamam food with no measures',
      build: () {
        when(edamamFoodRepository.fetchItem(edamamFood.id))
            .thenAnswer((_) async => await edamamFood.rebuild((b) => b..measures = null));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(edamamFoodMealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [
        MealElementLoading(),
        MealElementLoaded(
          mealElement: edamamFoodMealElement,
          food: edamamFood.rebuild((b) => b.measures = null),
        )
      ],
    );

    blocTest(
      'streams mealElement with custom food',
      build: () {
        when(mealElementRepository.stream(customFoodMealElement))
            .thenAnswer((_) => Stream<MealElement>.fromIterable([customFoodMealElement]));
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc.add(StreamMealElement(customFoodMealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [MealElementLoaded(mealElement: customFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.stream(customFoodMealElement)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async =>
          bloc..add(StreamMealElement(edamamFoodMealElement))..add(StreamMealElement(edamamFoodMealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [
        MealElementLoading(),
        MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood),
        MealElementLoading(),
        MealElementLoaded(mealElement: edamamFoodMealElement, food: edamamFood),
      ],
      verify: (bloc) async {
        verify(mealElementRepository.stream(edamamFoodMealElement)).called(2);
      },
    );

    blocTest(
      'loads mealElement',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc.add(Load(mealElement: edamamFoodMealElement)),
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(edamamFoodMealElement));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(Load(mealElement: edamamFoodMealElement.rebuild((b) => b.notes = 'asdf'))),
      expect: [
        MealElementLoaded(mealElement: edamamFoodMealElement),
        MealElementLoaded(mealElement: edamamFoodMealElement.rebuild((b) => b.notes = 'asdf'))
      ],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(edamamFoodMealElement));
      },
    );

    blocTest(
      'deletes entry',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc..add(Load(mealElement: edamamFoodMealElement))..add(const Delete()),
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(edamamFoodMealElement)).called(1);
        verify(analyticsService.logEvent('delete_meal_element')).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async =>
          bloc..add(Load(mealElement: edamamFoodMealElement))..add(const Delete())..add(const Delete()),
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(edamamFoodMealElement)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc..add(Load(mealElement: edamamFoodMealElement))..add(Update(edamamFoodMealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.update(edamamFoodMealElement)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element')).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(Update(edamamFoodMealElement))
        ..add(Update(edamamFoodMealElement))
        ..add(Update(edamamFoodMealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.update(edamamFoodMealElement)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc..add(Load(mealElement: edamamFoodMealElement))..add(const UpdateNotes('noted')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(edamamFoodMealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'notes')).called(1);
      },
    );

    blocTest(
      'debounces notes updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(const UpdateNotes('noted'))
        ..add(const UpdateNotes('note'))
        ..add(const UpdateNotes('not')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(edamamFoodMealElement, 'not')).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'updates food',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateFoodReference(edamamFoodMealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'food')).called(1);
      },
    );

    blocTest(
      'debounces food updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as25', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as26', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateFoodReference(
                edamamFoodMealElement, CustomFoodReference(id: 'as26', name: 'peanuts')))
            .called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'updates quantity',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(
          mealElementRepository: mealElementRepository,
          edamamFoodRepository: edamamFoodRepository,
        );
      },
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(edamamFoodMealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'quantity')).called(1);
      },
    );

    blocTest(
      'debounces quantity updates',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.2, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.3, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(
                edamamFoodMealElement, Quantity.unweighed(amount: 2.4, unit: 'cup')))
            .called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () => MealElementBloc(
        mealElementRepository: mealElementRepository,
        edamamFoodRepository: edamamFoodRepository,
      ),
      act: (bloc) async => bloc
        ..add(Load(mealElement: edamamFoodMealElement))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.0, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: edamamFoodMealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(edamamFoodMealElement, any)).called(1);
        verify(mealElementRepository.updateFoodReference(edamamFoodMealElement, any)).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    test('errors are recorded', () {
      expect(MealElementError(message: '') is ErrorRecorder, true);
    });
  });
}

class MockMealElementRepository extends Mock implements MealElementRepository {}

class MockEdamamFoodRepository extends Mock implements EdamamFoodRepository {}
