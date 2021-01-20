import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';

void main() {
  group('DiaryBloc', () {
    MockDiaryRepository diaryRepository;
    final mealEntry = MealEntry(
      id: '1',
      datetime: DateTime.now().toUtc(),
      mealElements: BuiltList<MealElement>([]),
      notes: 'Breakfast',
    );
    final bowelMovementEntry = BowelMovementEntry(
      id: '2',
      datetime: DateTime.now().toUtc(),
      bowelMovement: BowelMovement(volume: 3, type: 4),
      notes: 'Better than yesterday',
    );
    final symptomEntry = SymptomEntry(
        id: '3',
        datetime: DateTime.now().toUtc(),
        symptom: Symptom(severity: Severity.moderate, symptomType: SymptomType(id: 'symptomType1', name: 'Gas')));
    final allDiaryEntries = BuiltList<DiaryEntry>([mealEntry, bowelMovementEntry, symptomEntry]);

    setUp(() {
      diaryRepository = MockDiaryRepository();
      when(diaryRepository.streamAll())
          .thenAnswer((_) => Stream<BuiltList<DiaryEntry>>.fromIterable([allDiaryEntries]));
    });

    blocTest(
      'initial state is Loading',
      build: () async => DiaryBloc(repository: diaryRepository),
      skip: 0,
      expect: [DiaryLoading()],
    );

    blocTest(
      'streams all diary entries',
      build: () async => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(const StreamAll()),
      expect: [],
      verify: (bloc) async {
        verify(diaryRepository.streamAll()).called(1);
      },
    );

    blocTest(
      'loads diary entries',
      build: () async => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(Load(diaryEntries: allDiaryEntries)),
      expect: [DiaryLoaded(allDiaryEntries)],
      verify: (bloc) async {
        verifyNever(diaryRepository.streamAll());
      },
    );

    blocTest(
      'deletes meal entry',
      build: () async {
        mockBlocDelegate();
        return DiaryBloc(repository: diaryRepository);
      },
      act: (bloc) => bloc.add(Delete(mealEntry)),
      expect: [DiaryEntryDeleted(mealEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(mealEntry)).called(1);
        verify(analyticsService.logEvent('delete_meal_entry')).called(1);
      },
    );

    blocTest(
      'deletes symptom entry',
      build: () async {
        mockBlocDelegate();
        return DiaryBloc(repository: diaryRepository);
      },
      act: (bloc) => bloc.add(Delete(symptomEntry)),
      expect: [DiaryEntryDeleted(symptomEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(symptomEntry)).called(1);
        verify(analyticsService.logEvent('delete_symptom_entry')).called(1);
      },
    );

    blocTest(
      'deletes bowel movement entry',
      build: () async {
        mockBlocDelegate();
        return DiaryBloc(repository: diaryRepository);
      },
      act: (bloc) => bloc.add(Delete(bowelMovementEntry)),
      expect: [DiaryEntryDeleted(bowelMovementEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(bowelMovementEntry)).called(1);
        verify(analyticsService.logEvent('delete_bowel_movement_entry')).called(1);
      },
    );

    blocTest(
      'transitions to error state when stream throws error',
      build: () async {
        when(diaryRepository.streamAll()).thenThrow(Exception());
        return DiaryBloc(repository: diaryRepository);
      },
      act: (bloc) => bloc.add(const StreamAll()),
      expect: [isA<DiaryError>()],
    );
  });
}

class MockDiaryRepository extends Mock implements DiaryRepository {}
