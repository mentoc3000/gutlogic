import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/bowel_movement_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/resources/diary_repositories/bowel_movement_entry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../mocks/mock_bloc_delegate.dart';
import '../util/test_helpers.dart';

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

    blocTest(
      'initial state is Loading',
      build: () async => BowelMovementEntryBloc(repository: repository),
      skip: 0,
      expect: [BowelMovementEntryLoading()],
    );

    blocTest(
      'streams diary entry',
      build: () async => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () async => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc..add(StreamBowelMovementEntry(diaryEntry))..add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(2);
      },
    );

    blocTest(
      'enters error state when stream throws an error',
      build: () async {
        when(repository.stream(diaryEntry)).thenThrow(Exception());
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry), isA<BowelMovementEntryError>()],
    );

    blocTest(
      'creates and streams diary entry',
      build: () async {
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
        verify(analyticsService.logCreateBowelMovementEntry()).called(1);
      },
    );

    blocTest(
      'loads diary entries',
      build: () async => BowelMovementEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(LoadBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(DeleteBowelMovementEntry(diaryEntry)),
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(1);
        verify(analyticsService.logDeleteBowelMovementEntry()).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(UpdateBowelMovementEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
        verify(analyticsService.logUpdateBowelMovementEntry()).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadBowelMovementEntry(diaryEntry))..add(UpdateBowelMovementEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateBowelMovementEntry, 'field', 'dateTime');
      },
    );

    blocTest(
      'debounces datetime updates',
      build: () async {
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateBowelMovementEntryNotes('noted')),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateBowelMovementEntry, 'field', 'notes');
      },
    );

    blocTest(
      'debounces notes updates',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateType(3)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateType(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateBowelMovementEntry, 'field', 'type');
      },
    );

    blocTest(
      'debounces type updates',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async {
        mockBlocDelegate();
        return BowelMovementEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadBowelMovementEntry(diaryEntry))..add(const UpdateVolume(3)),
      wait: debounceWaitDuration,
      expect: [BowelMovementEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateVolume(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateBowelMovementEntry, 'field', 'volume');
      },
    );

    blocTest(
      'debounces volume updates',
      build: () async => BowelMovementEntryBloc(repository: repository),
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
      build: () async => BowelMovementEntryBloc(repository: repository),
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
