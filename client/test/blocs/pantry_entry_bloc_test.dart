import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/pantry_entry/pantry_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('PantryEntryBloc', () {
    PantryRepository repository;
    final food = CustomFood(id: 'foodId', name: 'ham hock');
    final foodReference = food.toFoodReference();
    final pantryEntry =
        PantryEntry(id: food.id, foodReference: foodReference, sensitivity: Sensitivity.moderate, notes: 'Some notes');
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockPantryRepository();
      when(repository.stream(pantryEntry)).thenAnswer((_) => Stream<PantryEntry>.fromIterable([pantryEntry]));
    });

    test('initial state', () {
      expect(PantryEntryBloc(repository: repository).state, PantryEntryLoading());
    });

    blocTest(
      'streams pantryentry',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc.add(StreamEntry(pantryEntry)),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.stream(pantryEntry)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc..add(StreamEntry(pantryEntry))..add(StreamEntry(pantryEntry)),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.stream(pantryEntry)).called(2);
      },
    );

    blocTest(
      'creates and streams pantry entry',
      build: () {
        mockBlocDelegate();
        when(repository.addFood(any)).thenAnswer((_) async => await pantryEntry);
        return PantryEntryBloc(repository: repository);
      },
      act: (bloc) => bloc.add(CreateAndStreamEntry(food)),
      wait: const Duration(milliseconds: 100),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.addFood(food)).called(1);
        verify(repository.stream(pantryEntry)).called(1);
        verify(analyticsService.logEvent('create_pantry_entry')).called(1);
      },
    );

    blocTest(
      'loads pantryentry',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc.add(Load(pantryEntry)),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verifyNever(repository.stream(pantryEntry));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc..add(Load(pantryEntry))..add(Load(pantryEntry.rebuild((b) => b.notes = 'asdf'))),
      expect: [PantryEntryLoaded(pantryEntry), PantryEntryLoaded(pantryEntry.rebuild((b) => b.notes = 'asdf'))],
      verify: (bloc) {
        verifyNever(repository.stream(pantryEntry));
      },
    );

    blocTest(
      'deletes entry',
      build: () {
        mockBlocDelegate();
        return PantryEntryBloc(repository: repository);
      },
      act: (bloc) => bloc..add(Load(pantryEntry))..add(const Delete()),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.delete(pantryEntry)).called(1);
        verify(analyticsService.logEvent('delete_pantry_entry')).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc..add(Load(pantryEntry))..add(const Delete())..add(const Delete()),
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.delete(pantryEntry)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () {
        mockBlocDelegate();
        return PantryEntryBloc(repository: repository);
      },
      act: (bloc) => bloc..add(Load(pantryEntry))..add(UpdateEntry(pantryEntry)),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateEntry(pantryEntry)).called(1);
        verify(analyticsService.logUpdateEvent('update_pantry_entry')).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc
        ..add(Load(pantryEntry))
        ..add(UpdateEntry(pantryEntry))
        ..add(UpdateEntry(pantryEntry))
        ..add(UpdateEntry(pantryEntry)),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateEntry(pantryEntry)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () {
        mockBlocDelegate();
        return PantryEntryBloc(repository: repository);
      },
      act: (bloc) => bloc..add(Load(pantryEntry))..add(const UpdateNotes('noted')),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_pantry_entry', 'notes')).called(1);
      },
    );

    blocTest(
      'debounces notes updates',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc
        ..add(Load(pantryEntry))
        ..add(const UpdateNotes('noted'))
        ..add(const UpdateNotes('note'))
        ..add(const UpdateNotes('not')),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates sensitivity',
      build: () {
        mockBlocDelegate();
        return PantryEntryBloc(repository: repository);
      },
      act: (bloc) => bloc..add(Load(pantryEntry))..add(const UpdateSensitivity(Sensitivity.severe)),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateSensitivity(pantryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_pantry_entry', 'sensitivity')).called(1);
      },
    );

    blocTest(
      'debounces food updates',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc
        ..add(Load(pantryEntry))
        ..add(const UpdateSensitivity(Sensitivity.moderate))
        ..add(const UpdateSensitivity(Sensitivity.mild))
        ..add(const UpdateSensitivity(Sensitivity.moderate))
        ..add(const UpdateSensitivity(Sensitivity.severe)),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateSensitivity(pantryEntry, Sensitivity.severe)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
    blocTest(
      'maps multiple debounced events',
      build: () => PantryEntryBloc(repository: repository),
      act: (bloc) => bloc
        ..add(Load(pantryEntry))
        ..add(const UpdateNotes('bad'))
        ..add(const UpdateSensitivity(Sensitivity.mild))
        ..add(const UpdateNotes('good'))
        ..add(const UpdateSensitivity(Sensitivity.none)),
      wait: debounceWaitDuration,
      expect: [PantryEntryLoaded(pantryEntry)],
      verify: (bloc) {
        verify(repository.updateNotes(pantryEntry, any)).called(1);
        verify(repository.updateSensitivity(pantryEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}

class MockPantryRepository extends Mock implements PantryRepository {}
