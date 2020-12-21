import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/symptom_entry/symptom_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';
import '../util/test_helpers.dart';

void main() {
  group('SymptomEntryBloc', () {
    SymptomEntryRepository repository;
    final symptomType = SymptomType(id: 'symptomType1', name: 'Gas');
    final DiaryEntry diaryEntry = SymptomEntry(
      id: '2',
      datetime: DateTime.now().toUtc(),
      symptom: Symptom(symptomType: symptomType, severity: 4.0),
      notes: 'Better than yesterday',
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockSymptomEntryRepository();
      when(repository.stream(diaryEntry)).thenAnswer((_) => Stream<DiaryEntry>.fromIterable([diaryEntry]));
    });

    blocTest(
      'initial state is Loading',
      build: () async => SymptomEntryBloc(repository: repository),
      skip: 0,
      expect: [SymptomEntryLoading()],
    );

    blocTest(
      'streams diary entry',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest(
      'does not debounce streaming',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc..add(StreamSymptomEntry(diaryEntry))..add(StreamSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(2);
      },
    );

    blocTest(
      'enters error state when stream throws an error',
      build: () async {
        when(repository.stream(diaryEntry)).thenThrow(Exception());
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry), isA<SymptomEntryError>()],
    );

    blocTest(
      'creates and streams diary entry from symptom type',
      build: () async {
        when(repository.createFrom(any)).thenAnswer((_) async => await diaryEntry);
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(CreateFromAndStreamSymptomEntry(symptomType)),
      wait: const Duration(milliseconds: 700),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.createFrom(any)).called(1);
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest(
      'loads diary entries',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(LoadSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'does not debounce loading',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async =>
          bloc..add(LoadSymptomEntry(diaryEntry))..add(LoadSymptomEntry(diaryEntry.rebuild((b) => b.notes = 'asdf'))),
      expect: [SymptomEntryLoaded(diaryEntry), SymptomEntryLoaded(diaryEntry.rebuild((b) => b.notes = 'asdf'))],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest(
      'deletes entry',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadSymptomEntry(diaryEntry))..add(DeleteSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(1);
        verify(analyticsService.logDeleteSymptomEntry()).called(1);
      },
    );

    blocTest(
      'does not debounce deletion',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(DeleteSymptomEntry(diaryEntry))
        ..add(DeleteSymptomEntry(diaryEntry)),
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(2);
      },
    );

    blocTest(
      'updates entry',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadSymptomEntry(diaryEntry))..add(UpdateSymptomEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
        verify(analyticsService.logUpdateSymptomEntry()).called(1);
      },
    );

    blocTest(
      'debounces entry updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptomEntry(diaryEntry))
        ..add(UpdateSymptomEntry(diaryEntry))
        ..add(UpdateSymptomEntry(diaryEntry)),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
      },
    );

    blocTest(
      'updates datetime',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async =>
          bloc..add(LoadSymptomEntry(diaryEntry))..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'dateTime');
      },
    );

    blocTest(
      'debounces datetime updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()))
        ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc())),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
      },
    );

    blocTest(
      'updates notes',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadSymptomEntry(diaryEntry))..add(const UpdateSymptomEntryNotes('noted')),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'notes');
      },
    );

    blocTest(
      'debounces notes updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(const UpdateSymptomEntryNotes('noted'))
        ..add(const UpdateSymptomEntryNotes('note'))
        ..add(const UpdateSymptomEntryNotes('not')),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
      },
    );

    blocTest(
      'updates symptom',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptom(Symptom(severity: 3, symptomType: SymptomType(id: 'symptomType1', name: 'Fat')))),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptom(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'symptom');
      },
    );

    blocTest(
      'debounces symptom updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptom(Symptom(severity: 3, symptomType: SymptomType(id: 'symptomType1', name: 'Fat'))))
        ..add(UpdateSymptom(Symptom(severity: 2, symptomType: SymptomType(id: 'symptomType1', name: 'Fat'))))
        ..add(UpdateSymptom(Symptom(severity: 1, symptomType: SymptomType(id: 'symptomType1', name: 'Fat'))))
        ..add(UpdateSymptom(Symptom(severity: 3, symptomType: SymptomType(id: 'symptomType1', name: 'Skinny')))),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptom(
                diaryEntry, Symptom(severity: 3, symptomType: SymptomType(id: 'symptomType1', name: 'Skinny'))))
            .called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates symptom type',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Tall'))),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomType(diaryEntry, SymptomType(id: 'symptomType1', name: 'Tall'))).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'type');
      },
    );

    blocTest(
      'debounces symptom type updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Tall')))
        ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Short')))
        ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Lean')))
        ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Bulky'))),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomType(diaryEntry, SymptomType(id: 'symptomType1', name: 'Bulky'))).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates symptom name',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadSymptomEntry(diaryEntry))..add(const UpdateSymptomName('Jeff')),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomName(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'symptom_name');
      },
    );

    blocTest(
      'debounces symptom name updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(const UpdateSymptomName('Moe'))
        ..add(const UpdateSymptomName('Larry'))
        ..add(const UpdateSymptomName('Curly')),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomName(diaryEntry, 'Curly')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'updates severity',
      build: () async {
        mockBlocDelegate();
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc..add(LoadSymptomEntry(diaryEntry))..add(const UpdateSeverity(3)),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, any)).called(1);
        verifyNamedParameter(analyticsService.logUpdateSymptomEntry, 'field', 'severity');
      },
    );

    blocTest(
      'debounces severity updates',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(const UpdateSeverity(3))
        ..add(const UpdateSeverity(4))
        ..add(const UpdateSeverity(3))
        ..add(const UpdateSeverity(2)),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, 2)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest(
      'maps multiple debounced events',
      build: () async => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(const UpdateSeverity(3))
        ..add(const UpdateSymptomName('Gas'))
        ..add(const UpdateSeverity(2)),
      wait: debounceWaitDuration,
      expect: [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, any)).called(1);
        verify(repository.updateSymptomName(diaryEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}

class MockSymptomEntryRepository extends Mock implements SymptomEntryRepository {}
