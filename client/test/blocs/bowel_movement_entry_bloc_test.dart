import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/bowel_movement_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('BowelMovementEntryBloc', () {
    BowelMovementEntryRepository repository;

    final DiaryEntry diaryEntry = BowelMovementEntry(
      id: '2',
      datetime: DateTime.now().toUtc(),
      bowelMovement: BowelMovement(volume: 3, type: 4),
      notes: 'Better than yesterday',
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockBowelMovementEntryRepository();
      when(repository.stream(diaryEntry)).thenAnswer((_) => Stream<DiaryEntry>.fromIterable([diaryEntry]));
    });

    test('initial state', () {
      expect(BowelMovementEntryBloc(repository: repository).state, BowelMovementEntryLoading());
    });

    blocTest(
      'streams diary entry',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc..add(StreamBowelMovementEntry(diaryEntry))..add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(2);
      },
    );

    blocTest(
      'enters error state when stream throws an error',
      build: () {
        when(repository.stream(diaryEntry)).thenThrow(Exception());
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry), isA<BowelMovementEntryError>()],
    );

    blocTest(
      'creates and streams diary entry',
      build: () {
        when(repository.create()).thenAnswer((_) async => await diaryEntry);
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(const CreateAndStreamBowelMovementEntry()),
      wait: const Duration(milliseconds: 100),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.create()).called(1);
        verify(repository.stream(diaryEntry)).called(1);
        verify(analyticsService.logEvent('create_bowel_movement_entry')).called(1);
      },
    );

    blocTest(
      'loads diary entries',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(LoadBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(LoadBowelMovementEntry(diaryEntry.rebuild((b) => b.notes = 'asdf'))),
      expect: [
        BowelMovementEntryLoaded(diaryEntry),
        BowelMovementEntryLoaded(diaryEntry.rebuild((b) => b.notes = 'asdf'))
      ],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'deletes entry',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(DeleteBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(1);
        verify(analyticsService.logEvent('delete_bowel_movement_entry')).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(DeleteBowelMovementEntry(diaryEntry))
        ..add(DeleteBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(UpdateBowelMovementEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
        verify(analyticsService.logUpdateEvent('update_bowel_movement_entry')).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(UpdateBowelMovementEntry(diaryEntry))
        ..add(UpdateBowelMovementEntry(diaryEntry))
        ..add(UpdateBowelMovementEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
      },
    );

    blocTest(
      'updates datetime',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadBowelMovementEntry(diaryEntry))..add(UpdateBowelMovementEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_bowel_movement_entry', 'dateTime')).called(1);
      },
    );

    blocTest(
      'debounces datetime updates',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(UpdateBowelMovementEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateBowelMovementEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateBowelMovementEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateBowelMovementEntryNotes('noted')),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_bowel_movement_entry', 'notes')).called(1);
      },
    );

    blocTest(
      'debounces notes updates',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(const UpdateBowelMovementEntryNotes('noted'))
        ..add(const UpdateBowelMovementEntryNotes('note'))
        ..add(const UpdateBowelMovementEntryNotes('not')),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, 'not')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates type',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateType(3)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateType(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_bowel_movement_entry', 'type')).called(1);
      },
    );

    blocTest(
      'debounces type updates',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(const UpdateType(3))
        ..add(const UpdateType(4))
        ..add(const UpdateType(3))
        ..add(const UpdateType(2)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateType(diaryEntry, 2)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates volume',
      build: () {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateVolume(3)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateVolume(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_bowel_movement_entry', 'volume')).called(1);
      },
    );

    blocTest(
      'debounces volume updates',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(const UpdateVolume(3))
        ..add(const UpdateVolume(2))
        ..add(const UpdateVolume(1)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateVolume(diaryEntry, 1)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadBowelMovementEntry(diaryEntry))
        ..add(const UpdateVolume(3))
        ..add(const UpdateType(3))
        ..add(const UpdateVolume(2))
        ..add(const UpdateType(2)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateVolume(diaryEntry, 2)).called(1);
        verify(repository.updateType(diaryEntry, 2)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}

class MockBowelMovementEntryRepository extends Mock implements BowelMovementEntryRepository {}
