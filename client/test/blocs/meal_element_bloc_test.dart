import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/resources/diary_repositories/meal_element_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('MealElementBloc', () {
    MealElementRepository mealElementRepository;
    final mealElement = MealElement(
      id: '2',
      foodReference: CustomFoodReference(id: '1234', name: 'silken tofu'),
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      mealElementRepository = MockMealElementRepository();
      when(mealElementRepository.stream(mealElement))
          .thenAnswer((_) => Stream<MealElement>.fromIterable([mealElement]));
    });

    test('initial state', () {
      expect(MealElementBloc(mealElementRepository: mealElementRepository).state, MealElementLoading());
    });

    blocTest(
      'streams mealElement',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc.add(StreamMealElement(mealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.stream(mealElement)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc..add(StreamMealElement(mealElement))..add(StreamMealElement(mealElement)),
      wait: const Duration(milliseconds: 10), // wait for add to be called before closing bloc
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.stream(mealElement)).called(2);
      },
    );

    blocTest(
      'loads mealElement',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc.add(Load(mealElement)),
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(mealElement));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc..add(Load(mealElement))..add(Load(mealElement.rebuild((b) => b.notes = 'asdf'))),
      expect: [
        MealElementLoaded(mealElement: mealElement),
        MealElementLoaded(mealElement: mealElement.rebuild((b) => b.notes = 'asdf'))
      ],
      verify: (bloc) async {
        verifyNever(mealElementRepository.stream(mealElement));
      },
    );

    blocTest(
      'deletes entry',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(mealElementRepository: mealElementRepository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(const Delete()),
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(mealElement)).called(1);
        verify(analyticsService.logEvent('delete_meal_element')).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc..add(Load(mealElement))..add(const Delete())..add(const Delete()),
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.delete(mealElement)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(mealElementRepository: mealElementRepository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(Update(mealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.update(mealElement)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element')).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async =>
          bloc..add(Load(mealElement))..add(Update(mealElement))..add(Update(mealElement))..add(Update(mealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.update(mealElement)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(mealElementRepository: mealElementRepository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(const UpdateNotes('noted')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(mealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'notes')).called(1);
      },
    );

    blocTest(
      'debounces notes updates',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(const UpdateNotes('noted'))
        ..add(const UpdateNotes('note'))
        ..add(const UpdateNotes('not')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateNotes(mealElement, 'not')).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'updates food',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(mealElementRepository: mealElementRepository);
      },
      act: (bloc) async =>
          bloc..add(Load(mealElement))..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateFoodReference(mealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'food')).called(1);
      },
    );

    blocTest(
      'debounces food updates',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as25', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as26', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateFoodReference(mealElement, CustomFoodReference(id: 'as26', name: 'peanuts')))
            .called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'updates quantity',
      build: () {
        mockBlocDelegate();
        return MealElementBloc(mealElementRepository: mealElementRepository);
      },
      act: (bloc) async =>
          bloc..add(Load(mealElement))..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(mealElement, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_element', 'quantity')).called(1);
      },
    );

    blocTest(
      'debounces quantity updates',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.1, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.2, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.3, unit: 'cup')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(mealElement, Quantity.unweighed(amount: 2.4, unit: 'cup')))
            .called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () => MealElementBloc(mealElementRepository: mealElementRepository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.4, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateQuantity(Quantity.unweighed(amount: 2.0, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement: mealElement)],
      verify: (bloc) async {
        verify(mealElementRepository.updateQuantity(mealElement, any)).called(1);
        verify(mealElementRepository.updateFoodReference(mealElement, any)).called(1);
        verifyNoMoreInteractions(mealElementRepository);
      },
    );
  });
}

class MockMealElementRepository extends Mock implements MealElementRepository {}
