import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/meal_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import 'meal_entry_bloc_test.mocks.dart';

@GenerateMocks([MealEntryRepository])
void main() {
  group('MealEntryBloc', () {
    late MockMealEntryRepository repository;

    final food = CustomFood(id: 'food1', name: 'Bacon');
    final foodReference = food.toFoodReference();
    final mealEntry = MealEntry(
      id: '2',
      datetime: DateTime.now().toUtc(),
      mealElements: <MealElement>[].build(),
      notes: 'Better than yesterday',
    );

    final mealElement = MealElement(id: '12', foodReference: foodReference);
    final mealElement2 = MealElement(id: '13', foodReference: foodReference);

    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockMealEntryRepository();
      when(repository.stream(mealEntry)).thenAnswer((_) => Stream<DiaryEntry>.fromIterable([mealEntry]));
      when(repository.createMealElement(any, any)).thenAnswer((_) async => null);
      when(repository.addMealElement(any, any)).thenAnswer((_) async => null);
    });

    test('initial state', () {
      expect(MealEntryBloc(repository: repository).state, MealEntryLoading());
    });

    blocTest<MealEntryBloc, MealEntryState>(
      'streams diary entry',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamMealEntry(mealEntry)),
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.stream(mealEntry)).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce streaming',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(StreamMealEntry(mealEntry))
          ..add(StreamMealEntry(mealEntry));
      },
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.stream(mealEntry)).called(2);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'enters error state when stream throws an error',
      build: () {
        when(repository.stream(mealEntry)).thenThrow(Exception());
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamMealEntry(mealEntry)),
      expect: () => [isA<MealEntryLoaded>(), isA<MealEntryError>()],
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'creates and streams diary entry',
      build: () {
        when(repository.create()).thenAnswer((_) async => await mealEntry);
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(const CreateAndStreamMealEntry()),
      wait: const Duration(milliseconds: 100),
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.create()).called(1);
        verify(repository.stream(mealEntry)).called(1);
        verify(analyticsService.logEvent('create_meal_entry')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'loads diary entries',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc.add(LoadMealEntry(mealEntry));
      },
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(mealEntry));
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce loading',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(LoadMealEntry(mealEntry.rebuild((b) => b.notes = 'asdf')));
      },
      expect: () => [
        MealEntryLoaded(mealEntry),
        MealEntryLoaded(mealEntry.rebuild((b) => b.notes = 'asdf')),
      ],
      verify: (bloc) async {
        verifyNever(repository.stream(mealEntry));
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'deletes entry',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(DeleteMealEntry(mealEntry));
      },
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.delete(mealEntry)).called(1);
        verify(analyticsService.logEvent('delete_meal_entry')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce deletion',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(DeleteMealEntry(mealEntry))
          ..add(DeleteMealEntry(mealEntry));
      },
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.delete(mealEntry)).called(2);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'updates entry',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(UpdateMealEntry(mealEntry));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(mealEntry)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_entry')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'debounces entry updates',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(UpdateMealEntry(mealEntry))
          ..add(UpdateMealEntry(mealEntry))
          ..add(UpdateMealEntry(mealEntry));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(mealEntry)).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'updates datetime',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(mealEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_entry', 'dateTime')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'debounces datetime updates',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(mealEntry, any)).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'updates notes',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(const UpdateMealEntryNotes('noted'));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(mealEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_entry', 'notes')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'debounces notes updates',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(const UpdateMealEntryNotes('noted'))
          ..add(const UpdateMealEntryNotes('note'))
          ..add(const UpdateMealEntryNotes('not'));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(mealEntry, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'adds mealElement',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(AddMealElement(food));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.createMealElement(mealEntry, food)).called(1);
        verify(analyticsService.logEvent('create_meal_element')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce adding mealElement',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(AddMealElement(food))
          ..add(AddMealElement(food));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.createMealElement(any, any)).called(2);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'reorders mealElement',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(const MoveMealElement(3, 2));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.reorderMealElement(mealEntry, 3, 2)).called(1);
        verify(analyticsService.logUpdateEvent('update_meal_entry', 'move_meal_element')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce reordering mealElement',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(const MoveMealElement(3, 2))
          ..add(const MoveMealElement(2, 3))
          ..add(const MoveMealElement(3, 1))
          ..add(const MoveMealElement(1, 2));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.reorderMealElement(any, any, any)).called(4);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'removes mealElement',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealElement));
      },
      wait: debounceWaitDuration,
      expect: () => [
        MealEntryLoaded(mealEntry),
        MealElementDeleted(mealEntry: mealEntry, mealElement: mealElement),
      ],
      verify: (bloc) async {
        verify(repository.removeMealElement(mealEntry, any)).called(1);
        verify(analyticsService.logEvent('delete_meal_element')).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'does not debounce mealElement removal',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealElement))
          ..add(DeleteMealElement(mealEntry: mealEntry, mealElement: mealElement2));
      },
      wait: debounceWaitDuration,
      expect: () => [
        MealEntryLoaded(mealEntry),
        MealElementDeleted(mealEntry: mealEntry, mealElement: mealElement),
        MealElementDeleted(mealEntry: mealEntry, mealElement: mealElement2),
      ],
      verify: (bloc) async {
        verify(repository.removeMealElement(mealEntry, any)).called(2);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'undeletes mealElement',
      build: () {
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(UndeleteMealElement(mealEntry: mealEntry, mealElement: mealElement));
      },
      wait: debounceWaitDuration,
      expect: () => [
        MealEntryLoaded(mealEntry),
      ],
      verify: (bloc) async {
        verify(repository.addMealElement(mealEntry, any)).called(1);
      },
    );

    blocTest<MealEntryBloc, MealEntryState>(
      'maps multiple debounced events',
      build: () => MealEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadMealEntry(mealEntry))
          ..add(const UpdateMealEntryNotes('noted'))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
          ..add(const UpdateMealEntryNotes('pass'))
          ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()));
      },
      wait: debounceWaitDuration,
      expect: () => [MealEntryLoaded(mealEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(mealEntry, any)).called(1);
        verify(repository.updateDateTime(mealEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(MealEntryError(message: '') is ErrorRecorder, true);
    });
  });
}
