import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/meal_entry/meal_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/resources/diary_repositories/meal_entry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';
import '../util/test_helpers.dart';

void main() {
  group('MealEntryBloc', () {
    MealEntryRepository repository;
    final food = CustomFood(id: 'food1', name: 'Bacon');
    final foodReference = food.toFoodReference();
    final DiaryEntry diaryEntry = MealEntry(
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
      when(repository.stream(diaryEntry)).thenAnswer((_) => Stream<DiaryEntry>.fromIterable([diaryEntry]));
    });

    blocTest(
      'initial state is Loading',
      build: () async => MealEntryBloc(repository: repository),
      skip: 0,
      expect: [MealEntryLoading()],
    );

    blocTest(
      'streams diary entry',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc..add(StreamMealEntry(diaryEntry))..add(StreamMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(2);
      },
    );

    blocTest(
      'enters error state when stream throws an error',
      build: () async {
        when(repository.stream(diaryEntry)).thenThrow(Exception());
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry), isA<MealEntryError>()],
    );

    blocTest(
      'creates and streams diary entry',
      build: () async {
        mockBlocDelegate();
        when(repository.create()).thenAnswer((_) async => await diaryEntry);
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(const CreateAndStreamMealEntry()),
      wait: const Duration(milliseconds: 100),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.create()).called(1);
        verify(repository.stream(diaryEntry)).called(1);
        verify(analyticsService.logCreateMealEntry()).called(1);
      },
    );

    blocTest(
      'loads diary entries',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(LoadMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async =>
          bloc..add(LoadMealEntry(diaryEntry))..add(LoadMealEntry(diaryEntry.rebuild((b) => b.notes = 'asdf'))),
      expect: [MealEntryLoaded(diaryEntry), MealEntryLoaded(diaryEntry.rebuild((b) => b.notes = 'asdf'))],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'deletes entry',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(DeleteMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(1);
        verify(analyticsService.logDeleteMealEntry()).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async =>
          bloc..add(LoadMealEntry(diaryEntry))..add(DeleteMealEntry(diaryEntry))..add(DeleteMealEntry(diaryEntry)),
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(UpdateMealEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
        verify(analyticsService.logUpdateMealEntry()).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(UpdateMealEntry(diaryEntry))
        ..add(UpdateMealEntry(diaryEntry))
        ..add(UpdateMealEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
      },
    );

    blocTest(
      'updates datetime',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(UpdateMealEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealEntry, 'field', 'dateTime');
      },
    );

    blocTest(
      'debounces datetime updates',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateMealEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(const UpdateMealEntryNotes('noted')),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealEntry, 'field', 'notes');
      },
    );

    blocTest(
      'debounces notes updates',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(const UpdateMealEntryNotes('noted'))
        ..add(const UpdateMealEntryNotes('note'))
        ..add(const UpdateMealEntryNotes('not')),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'adds mealElement',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(AddMealElement(food)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.createMealElement(diaryEntry, food)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealEntry, 'field', 'add_meal_element');
      },
    );

    blocTest(
      'does not debounce adding mealElement',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(AddMealElement(food))..add(AddMealElement(food)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.createMealElement(any, any)).called(2);
      },
    );

    blocTest(
      'reorders mealElement',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadMealEntry(diaryEntry))..add(const MoveMealElement(3, 2)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.reorderMealElement(diaryEntry, 3, 2)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealEntry, 'field', 'move_meal_element');
      },
    );

    blocTest(
      'does not debounce reordering mealElement',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(const MoveMealElement(3, 2))
        ..add(const MoveMealElement(2, 3))
        ..add(const MoveMealElement(3, 1))
        ..add(const MoveMealElement(1, 2)),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.reorderMealElement(any, any, any)).called(4);
      },
    );

    blocTest(
      'removes mealElement',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadMealEntry(diaryEntry))..add(DeleteMealElement(mealEntry: diaryEntry, mealElement: mealElement)),
      wait: debounceWaitDuration,
      expect: [
        MealEntryLoaded(diaryEntry),
        MealElementDeleted(mealEntry: diaryEntry, mealElement: mealElement),
      ],
      verify: (bloc) async {
        verify(repository.removeMealElement(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateMealEntry, 'field', 'remove_meal_element');
      },
    );

    blocTest(
      'does not debounce mealElement removal',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(DeleteMealElement(mealEntry: diaryEntry, mealElement: mealElement))
        ..add(DeleteMealElement(mealEntry: diaryEntry, mealElement: mealElement2)),
      wait: debounceWaitDuration,
      expect: [
        MealEntryLoaded(diaryEntry),
        MealElementDeleted(mealEntry: diaryEntry, mealElement: mealElement),
        MealElementDeleted(mealEntry: diaryEntry, mealElement: mealElement2),
      ],
      verify: (bloc) async {
        verify(repository.removeMealElement(diaryEntry, any)).called(2);
      },
    );

    blocTest(
      'undeletes mealElement',
      build: () async {
        mockBlocDelegate();
        return MealEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(UndeleteMealElement(mealEntry: diaryEntry, mealElement: mealElement)),
      wait: debounceWaitDuration,
      expect: [
        MealEntryLoaded(diaryEntry),
      ],
      verify: (bloc) async {
        verify(repository.addMealElement(diaryEntry, any)).called(1);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () async => MealEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadMealEntry(diaryEntry))
        ..add(const UpdateMealEntryNotes('noted'))
        ..add(UpdateMealEntryDateTime(DateTime.now().toUtc()))
        ..add(const UpdateMealEntryNotes('pass'))
        ..add(UpdateMealEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [MealEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}

class MockMealEntryRepository extends Mock implements MealEntryRepository {}
