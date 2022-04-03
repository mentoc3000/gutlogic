import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/src/list.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'diary_bloc_test.mocks.dart';

@GenerateMocks([DiaryRepository])
void main() {
  group('DiaryBloc', () {
    late MockDiaryRepository diaryRepository;

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
      symptom: Symptom(severity: Severity.moderate, symptomType: SymptomType(id: 'symptomType1', name: 'Gas')),
    );
    final allDiaryEntries = BuiltList<DiaryEntry>([mealEntry, bowelMovementEntry, symptomEntry]);

    setUp(() {
      diaryRepository = MockDiaryRepository();
      when(diaryRepository.streamAll())
          .thenAnswer((_) => Stream<BuiltList<DiaryEntry>>.fromIterable([allDiaryEntries]));
    });

    test('initial state', () {
      expect(DiaryBloc(repository: diaryRepository).state, DiaryLoading());
    });

    blocTest<DiaryBloc, DiaryState>(
      'streams all diary entries',
      build: () => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(const StreamAllDiary()),
      expect: () => [
        DiaryLoading(),
        DiaryLoaded(allDiaryEntries),
      ],
      verify: (bloc) async {
        verify(diaryRepository.streamAll()).called(1);
      },
    );

    blocTest<DiaryBloc, DiaryState>(
      'loads diary entries',
      build: () => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(Load(diaryEntries: allDiaryEntries)),
      expect: () => [DiaryLoaded(allDiaryEntries)],
      verify: (bloc) async {
        verifyNever(diaryRepository.streamAll());
      },
    );

    blocTest<DiaryBloc, DiaryState>(
      'deletes meal entry',
      build: () => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(Delete(mealEntry)),
      expect: () => [DiaryEntryDeleted(mealEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(mealEntry)).called(1);
        // verify(analyticsService.logEvent('delete_meal_entry')).called(1);
      },
    );

    blocTest<DiaryBloc, DiaryState>(
      'deletes symptom entry',
      build: () => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(Delete(symptomEntry)),
      expect: () => [DiaryEntryDeleted(symptomEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(symptomEntry)).called(1);
        // verify(analyticsService.logEvent('delete_symptom_entry')).called(1);
      },
    );

    blocTest<DiaryBloc, DiaryState>(
      'deletes bowel movement entry',
      build: () => DiaryBloc(repository: diaryRepository),
      act: (bloc) => bloc.add(Delete(bowelMovementEntry)),
      expect: () => [DiaryEntryDeleted(bowelMovementEntry)],
      verify: (bloc) async {
        verify(diaryRepository.delete(bowelMovementEntry)).called(1);
        // verify(analyticsService.logEvent('delete_bowel_movement_entry')).called(1);
      },
    );

    blocTest<DiaryBloc, DiaryState>(
      'transitions to error state when stream throws error',
      build: () {
        when(diaryRepository.streamAll()).thenThrow(Exception());
        return DiaryBloc(repository: diaryRepository);
      },
      expect: () => [DiaryLoading(), isA<DiaryError>()],
      act: (bloc) => bloc.add(const StreamAllDiary()),
    );

    test('errors are recorded', () {
      // ignore: unnecessary_type_check
      expect(DiaryError(message: '') is ErrorRecorder, true);
    });
  });
}
