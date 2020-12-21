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
import '../util/test_helpers.dart';

void main() {
  group('MealElementBloc', () {
    MealElementRepository repository;
    final mealElement = MealElement(
      id: '2',
      foodReference: CustomFoodReference(
        id: '1234',
        name: 'silken tofu',
      ),
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockMealElementRepository();
      when(repository.stream(mealElement)).thenAnswer((_) => Stream<MealElement>.fromIterable([mealElement]));
    });

    blocTest(
      'initial state is Loading',
      build: () async => MealElementBloc(repository: repository),
      skip: 0,
      expect: [MealElementLoading()],
    );

    blocTest(
      'streams mealElement',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamMealElement(mealElement)),
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.stream(mealElement)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc..add(StreamMealElement(mealElement))..add(StreamMealElement(mealElement)),
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.stream(mealElement)).called(2);
      },
    );

    blocTest(
      'loads mealElement',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc.add(Load(mealElement)),
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verifyNever(repository.stream(mealElement));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc..add(Load(mealElement))..add(Load(mealElement.rebuild((b) => b.notes = 'asdf'))),
      expect: [MealElementLoaded(mealElement), MealElementLoaded(mealElement.rebuild((b) => b.notes = 'asdf'))],
      verify: (bloc) async {
        verifyNever(repository.stream(mealElement));
      },
    );

    blocTest(
      'deletes entry',
      build: () async {
        mockBlocDelegate();
        return MealElementBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(const Delete()),
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.delete(mealElement)).called(1);
        verify(analyticsService.logDeleteMealElement()).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc..add(Load(mealElement))..add(const Delete())..add(const Delete()),
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.delete(mealElement)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () async {
        mockBlocDelegate();
        return MealElementBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(Update(mealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.update(mealElement)).called(1);
        verify(analyticsService.logUpdateMealElement()).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async =>
          bloc..add(Load(mealElement))..add(Update(mealElement))..add(Update(mealElement))..add(Update(mealElement)),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.update(mealElement)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () async {
        mockBlocDelegate();
        return MealElementBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(const UpdateNotes('noted')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateNotes(mealElement, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealElement, 'field', 'notes');
      },
    );

    blocTest(
      'debounces notes updates',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(const UpdateNotes('noted'))
        ..add(const UpdateNotes('note'))
        ..add(const UpdateNotes('not')),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateNotes(mealElement, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates food',
      build: () async {
        mockBlocDelegate();
        return MealElementBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(Load(mealElement))..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateFoodReference(mealElement, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealElement, 'field', 'food');
      },
    );

    blocTest(
      'debounces food updates',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as25', name: 'peanuts')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as26', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateFoodReference(mealElement, CustomFoodReference(id: 'as26', name: 'peanuts'))).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates quantity',
      build: () async {
        mockBlocDelegate();
        return MealElementBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(Load(mealElement))..add(UpdateQuantity(Quantity(amount: 2.1, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateQuantity(mealElement, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealElement, 'field', 'quantity');
      },
    );

    blocTest(
      'debounces quantity updates',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateQuantity(Quantity(amount: 2.1, unit: 'cup')))
        ..add(UpdateQuantity(Quantity(amount: 2.2, unit: 'cup')))
        ..add(UpdateQuantity(Quantity(amount: 2.3, unit: 'cup')))
        ..add(UpdateQuantity(Quantity(amount: 2.4, unit: 'cup'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateQuantity(mealElement, Quantity(amount: 2.4, unit: 'cup'))).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () async => MealElementBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(Load(mealElement))
        ..add(UpdateQuantity(Quantity(amount: 2.4, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as23', name: 'peanuts')))
        ..add(UpdateQuantity(Quantity(amount: 2.0, unit: 'cup')))
        ..add(UpdateFoodReference(CustomFoodReference(id: 'as24', name: 'peanuts'))),
      wait: debounceWaitDuration,
      expect: [MealElementLoaded(mealElement)],
      verify: (bloc) async {
        verify(repository.updateQuantity(mealElement, any)).called(1);
        verify(repository.updateFoodReference(mealElement, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}

class MockMealElementRepository extends Mock implements MealElementRepository {}
