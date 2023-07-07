import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/diary_entry/diary_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/analysis_service.dart';
import 'package:gutlogic/resources/diary_repositories/diary_repository.dart';
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/util/date_time_ext.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'analysis_service_test.mocks.dart';

@GenerateMocks([DiaryRepository, PantryService, IrritantService])
void main() {
  late DiaryRepository diaryRepository;
  late PantryService pantryService;
  late IrritantService irritantService;
  late AnalysisService analysisService;

  final emptyIrritantNames = BuiltSet<String>();
  final irritantNames = {'Fructose', 'GOS', 'Lactose'}.build();

  final foodRef1 = EdamamFoodReference(id: 'e1', name: 'Apple');
  final foodRef2 = EdamamFoodReference(id: 'e2', name: 'Broccoli');

  final emptyPantry = BuiltList<PantryEntry>();
  final pantry = [
    PantryEntry(
      userFoodDetailsId: 'userFoodDetailsId1',
      foodReference: foodRef1,
      sensitivity: Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.user),
      notes: null,
    ),
    PantryEntry(
      userFoodDetailsId: 'userFoodDetailsId2',
      foodReference: foodRef2,
      sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
      notes: null,
    ),
  ].build();

  final irritants = {
    foodRef1: [
      Irritant(name: 'Fructose', concentration: 1, dosePerServing: 100),
      Irritant(name: 'GOS', concentration: 0, dosePerServing: 0),
      Irritant(name: 'Lactose', concentration: 0, dosePerServing: 0),
    ].build(),
    foodRef2: [
      Irritant(name: 'Fructose', concentration: 1, dosePerServing: 100),
      Irritant(name: 'GOS', concentration: 1, dosePerServing: 100),
      Irritant(name: 'Lactose', concentration: 0, dosePerServing: 0),
    ].build(),
  };

  final mild = Symptom(symptomType: SymptomType(id: 'id', name: 'Gas'), severity: Severity.mild);
  final moderate = Symptom(symptomType: SymptomType(id: 'id', name: 'Gas'), severity: Severity.moderate);
  final intense = Symptom(symptomType: SymptomType(id: 'id', name: 'Gas'), severity: Severity.intense);
  final severe = Symptom(symptomType: SymptomType(id: 'id', name: 'Pain'), severity: Severity.severe);

  final today = DateTime.now().toLocalMidnight();
  final emptyDiary = BuiltList<DiaryEntry>();
  final diary = [
    MealEntry(id: 'id', datetime: today.subtractDays(5), mealElements: BuiltList<MealElement>()),
    SymptomEntry(id: 'id', datetime: today.subtractDays(5), symptom: mild),
    SymptomEntry(id: 'id', datetime: today.subtractDays(5), symptom: moderate),
    SymptomEntry(id: 'id', datetime: today.subtractDays(3), symptom: intense),
    MealEntry(id: 'id', datetime: today.subtractDays(1), mealElements: BuiltList<MealElement>()),
    SymptomEntry(id: 'id', datetime: today, symptom: severe),
  ].toBuiltList();

  group('AnalysisService', () {
    setUp(() async {
      diaryRepository = MockDiaryRepository();
      pantryService = MockPantryService();
      irritantService = MockIrritantService();
      analysisService = AnalysisService(
        pantryService: pantryService,
        diaryRepository: diaryRepository,
        irritantService: irritantService,
      );
    });

    group('foodCountByIrritantAndLevel', () {
      test('Empty irritants', () async {
        when(irritantService.names()).thenAnswer((_) => Future.value(emptyIrritantNames));
        when(pantryService.streamAll()).thenAnswer((realInvocation) => Stream.value(pantry));
        for (final element in irritants.entries) {
          when(irritantService.ofRef(element.key)).thenAnswer((realInvocation) => Stream.value(element.value));
        }

        final foodCount = analysisService.foodCountByIrritantAndLevel();
        final expected = BuiltMap<String, BuiltMap<SensitivityLevel, int>>();
        await expectLater(foodCount, emits(expected));
      });

      test('Empty pantry', () async {
        when(irritantService.names()).thenAnswer((_) => Future.value(irritantNames));
        when(pantryService.streamAll()).thenAnswer((realInvocation) => Stream.value(emptyPantry));

        final foodCount = analysisService.foodCountByIrritantAndLevel();
        final expected = {
          'Fructose': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 0,
            SensitivityLevel.moderate: 0,
            SensitivityLevel.severe: 0,
          }.build(),
          'GOS': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 0,
            SensitivityLevel.moderate: 0,
            SensitivityLevel.severe: 0,
          }.build(),
          'Lactose': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 0,
            SensitivityLevel.moderate: 0,
            SensitivityLevel.severe: 0,
          }.build(),
        }.build();
        await expectLater(foodCount, emits(expected));
      });

      test('Full response', () async {
        when(irritantService.names()).thenAnswer((_) => Future.value(irritantNames));
        when(pantryService.streamAll()).thenAnswer((realInvocation) => Stream.value(pantry));
        for (final element in irritants.entries) {
          when(irritantService.ofRef(element.key)).thenAnswer((realInvocation) => Stream.value(element.value));
        }

        final foodCount = analysisService.foodCountByIrritantAndLevel();
        final expected = {
          'Fructose': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 1,
            SensitivityLevel.moderate: 1,
            SensitivityLevel.severe: 0,
          }.build(),
          'GOS': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 0,
            SensitivityLevel.moderate: 1,
            SensitivityLevel.severe: 0,
          }.build(),
          'Lactose': {
            SensitivityLevel.unknown: 0,
            SensitivityLevel.none: 0,
            SensitivityLevel.mild: 0,
            SensitivityLevel.moderate: 0,
            SensitivityLevel.severe: 0,
          }.build(),
        }.build();
        await expectLater(foodCount, emits(expected));
      });
    });

    group('recentSeverity', () {
      test('groups and sorts', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final recentSeverity = analysisService.recentSeverity(count: 6);
        final expected = BuiltMap<DateTime, Severity?>({
          today: Severity.severe,
          today.subtractDays(1): null,
          today.subtractDays(2): null,
          today.subtractDays(3): Severity.intense,
          today.subtractDays(4): null,
          today.subtractDays(5): Severity.moderate,
        });

        await expectLater(recentSeverity, emits(expected));
      });

      test('takes a subset', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final recentSeverity = analysisService.recentSeverity(count: 3);
        final expected = BuiltMap<DateTime, Severity?>({
          today: Severity.severe,
          today.subtractDays(1): null,
          today.subtractDays(2): null,
        });

        await expectLater(recentSeverity, emits(expected));
      });

      test('pads to fill count', () async {
        when(diaryRepository.streamAll()).thenAnswer((realInvocation) => Stream.value(emptyDiary));

        final recentSeverity = analysisService.recentSeverity(count: 3);
        final expected = BuiltMap<DateTime, Severity?>({
          today: null,
          today.subtractDays(1): null,
          today.subtractDays(2): null,
        });

        await expectLater(recentSeverity, emits(expected));
      });
    });

    group('symptomTypeCount', () {
      test('counts SymptomTypes', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final symptomTypeCount = analysisService.symptomTypeCount();
        final expected = BuiltMap<SymptomType, int>({
          SymptomType(id: 'id', name: 'Gas'): 3,
          SymptomType(id: 'id', name: 'Pain'): 1,
        });

        await expectLater(symptomTypeCount, emits(expected));
      });

      test('counts SymptomTypes since date', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final since = today.subtractDays(4);
        final symptomTypeCount = analysisService.symptomTypeCount(since: since);
        final expected = BuiltMap<SymptomType, int>({
          SymptomType(id: 'id', name: 'Gas'): 1,
          SymptomType(id: 'id', name: 'Pain'): 1,
        });

        await expectLater(symptomTypeCount, emits(expected));
      });

      test('counts empty diary', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(emptyDiary));

        final symptomTypeCount = analysisService.symptomTypeCount();
        final expected = BuiltMap<SymptomType, int>();

        await expectLater(symptomTypeCount, emits(expected));
      });
    });

    group('diaryStreak', () {
      test('counts streak', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final symptomTypeCount = analysisService.diaryStreak(count: 10);
        final expected = BuiltMap<DateTime, int>({
          today: 2,
          today.subtractDays(1): 1,
          today.subtractDays(2): 0,
          today.subtractDays(3): 1,
          today.subtractDays(4): 0,
          today.subtractDays(5): 1,
          today.subtractDays(6): 0,
          today.subtractDays(7): 0,
          today.subtractDays(8): 0,
          today.subtractDays(9): 0,
        });

        await expectLater(symptomTypeCount, emits(expected));
      });

      test('counts latest streak', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(diary));

        final symptomTypeCount = analysisService.diaryStreak(count: 1);
        final expected = BuiltMap<DateTime, int>({today: 2});

        await expectLater(symptomTypeCount, emits(expected));
      });

      test('counts empty diary', () async {
        when(diaryRepository.streamAll()).thenAnswer((_) => Stream.value(emptyDiary));

        final symptomTypeCount = analysisService.diaryStreak(count: 3);
        final expected = BuiltMap<DateTime, int>({
          today: 0,
          today.subtractDays(1): 0,
          today.subtractDays(2): 0,
        });

        await expectLater(symptomTypeCount, emits(expected));
      });
    });
  });
}
