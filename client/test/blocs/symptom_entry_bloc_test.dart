import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/symptom_entry/symptom_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/symptom_entry_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import 'symptom_entry_bloc_test.mocks.dart';

@GenerateMocks([SymptomEntryRepository])
void main() {
  group('SymptomEntryBloc', () {
    late MockSymptomEntryRepository repository;
    final symptomType = SymptomType(id: 'symptomType1', name: 'Gas');
    final diaryEntry = SymptomEntry(
      id: '2',
      datetime: DateTime.now().toUtc(),
      symptom: Symptom(symptomType: symptomType, severity: Severity.severe),
      notes: 'Better than yesterday',
    );
    final debounceWaitDuration = debounceDuration + const Duration(milliseconds: 100);

    setUp(() {
      repository = MockSymptomEntryRepository();
      when(repository.stream(diaryEntry)).thenAnswer((_) => Stream<DiaryEntry>.fromIterable([diaryEntry]));
    });

    test('initial state', () {
      expect(SymptomEntryBloc(repository: repository).state, SymptomEntryLoading());
    });

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'streams diary entry',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(StreamSymptomEntry(diaryEntry)),
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'does not debounce streaming',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(StreamSymptomEntry(diaryEntry))
          ..add(StreamSymptomEntry(diaryEntry));
      },
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.stream(diaryEntry)).called(2);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'enters error state when stream throws an error',
      build: () {
        when(repository.stream(diaryEntry)).thenThrow(Exception());
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(StreamSymptomEntry(diaryEntry)),
      expect: () => [SymptomEntryLoaded(diaryEntry), isA<SymptomEntryError>()],
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'creates and streams diary entry from symptom type',
      build: () {
        when(repository.createFrom(any)).thenAnswer((_) async => await diaryEntry);
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async => bloc.add(CreateFromAndStreamSymptomEntry(symptomType)),
      wait: const Duration(milliseconds: 700),
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.createFrom(any)).called(1);
        verify(repository.stream(diaryEntry)).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'loads diary entries',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc.add(LoadSymptomEntry(diaryEntry)),
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'does not debounce loading',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(LoadSymptomEntry(diaryEntry.rebuild((b) => b.notes = 'asdf')));
      },
      expect: () => [SymptomEntryLoaded(diaryEntry), SymptomEntryLoaded(diaryEntry.rebuild((b) => b.notes = 'asdf'))],
      verify: (bloc) async {
        verifyNever(repository.stream(diaryEntry));
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'deletes entry',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(DeleteSymptomEntry(diaryEntry));
      },
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(1);
        verify(analyticsService.logEvent('delete_symptom_entry')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'does not debounce deletion',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(DeleteSymptomEntry(diaryEntry))
          ..add(DeleteSymptomEntry(diaryEntry));
      },
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.delete(diaryEntry)).called(2);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates entry',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntry(diaryEntry));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces entry updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntry(diaryEntry));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateEntry(diaryEntry)).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates datetime',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'dateTime')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces datetime updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()))
          ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()))
          ..add(UpdateSymptomEntryDateTime(DateTime.now().toUtc()));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateDateTime(diaryEntry, any)).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates notes',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSymptomEntryNotes('noted'));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'notes')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces notes updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSymptomEntryNotes('noted'))
          ..add(const UpdateSymptomEntryNotes('note'))
          ..add(const UpdateSymptomEntryNotes('not'));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateNotes(diaryEntry, any)).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates symptom',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptom(
              Symptom(severity: Severity.intense, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Fat'))));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptom(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'symptom')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces symptom updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptom(
              Symptom(severity: Severity.intense, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Fat'))))
          ..add(UpdateSymptom(
              Symptom(severity: Severity.moderate, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Fat'))))
          ..add(UpdateSymptom(
              Symptom(severity: Severity.mild, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Fat'))))
          ..add(UpdateSymptom(
              Symptom(severity: Severity.intense, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Skinny'))));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptom(diaryEntry,
                Symptom(severity: Severity.intense, symptomType: SymptomType(id: 'symptomTyp.mild', name: 'Skinny'))))
            .called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates symptom type',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Tall')));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomType(diaryEntry, SymptomType(id: 'symptomType1', name: 'Tall'))).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'type')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces symptom type updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Tall')))
          ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Short')))
          ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Lean')))
          ..add(UpdateSymptomType(SymptomType(id: 'symptomType1', name: 'Bulky')));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomType(diaryEntry, SymptomType(id: 'symptomType1', name: 'Bulky'))).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates symptom name',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSymptomName('Jeff'));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomName(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'symptom_name')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces symptom name updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async => bloc
        ..add(LoadSymptomEntry(diaryEntry))
        ..add(const UpdateSymptomName('Moe'))
        ..add(const UpdateSymptomName('Larry'))
        ..add(const UpdateSymptomName('Curly')),
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSymptomName(diaryEntry, 'Curly')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'updates severity',
      build: () {
        return SymptomEntryBloc(repository: repository);
      },
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSeverity(Severity.intense));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, any)).called(1);
        verify(analyticsService.logUpdateEvent('update_symptom_entry', 'severity')).called(1);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'debounces severity updates',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSeverity(Severity.intense))
          ..add(const UpdateSeverity(Severity.severe))
          ..add(const UpdateSeverity(Severity.intense))
          ..add(const UpdateSeverity(Severity.moderate));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, Severity.moderate)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<SymptomEntryBloc, SymptomEntryState>(
      'maps multiple debounced events',
      build: () => SymptomEntryBloc(repository: repository),
      act: (bloc) async {
        bloc
          ..add(LoadSymptomEntry(diaryEntry))
          ..add(const UpdateSeverity(Severity.intense))
          ..add(const UpdateSymptomName('Gas'))
          ..add(const UpdateSeverity(Severity.moderate));
      },
      wait: debounceWaitDuration,
      expect: () => [SymptomEntryLoaded(diaryEntry)],
      verify: (bloc) async {
        verify(repository.updateSeverity(diaryEntry, any)).called(1);
        verify(repository.updateSymptomName(diaryEntry, any)).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(SymptomEntryError(message: '') is ErrorRecorder, true);
    });
  });
}
