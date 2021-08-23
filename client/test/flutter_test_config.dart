import 'dart:async';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gutlogic/blocs/bowel_movement_entry/bowel_movement_entry.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/blocs/food/food.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/blocs/meal_entry/meal_entry.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/blocs/pantry_filter/pantry_filter.dart';
import 'package:gutlogic/blocs/pantry_sort/pantry_sort.dart';
import 'package:gutlogic/blocs/pantry_entry/pantry_entry.dart';
import 'package:gutlogic/blocs/symptom_entry/symptom_entry.dart';
import 'package:gutlogic/blocs/symptom_type/symptom_type.dart';
import 'package:gutlogic/blocs/gut_logic_bloc_observer.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/food_reference/food_reference.dart';
import 'package:gutlogic/models/user_food_details_api.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/pantry/pantry_sort.dart';
import 'package:gutlogic/models/pantry/pantry_filter.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';

import 'flutter_test_config.mocks.dart';

class BowelMovementEntryEventFake extends Fake implements BowelMovementEntryEvent {}

class DiaryEventFake extends Fake implements DiaryEvent {}

class FoodEventFake extends Fake implements FoodEvent {}

class MealElementEventFake extends Fake implements MealElementEvent {}

class MealEntryEventFake extends Fake implements MealEntryEvent {}

class PantryEventFake extends Fake implements PantryEvent {}

class PantryEntryEventFake extends Fake implements PantryEntryEvent {}

class SymptomEntryEventFake extends Fake implements SymptomEntryEvent {}

class SymptomTypeEventFake extends Fake implements SymptomTypeEvent {}

late MockAnalyticsService analyticsService;
late MockCrashlyticsService crashlyticsService;

@GenerateMocks([AnalyticsService, CrashlyticsService])
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Mute logging for tests
  Logger.level = Level.nothing;

  // Stub out analytics
  analyticsService = MockAnalyticsService();
  crashlyticsService = MockCrashlyticsService();
  Bloc.observer = GutLogicBlocObserver(
    analytics: analyticsService,
    crashlytics: crashlyticsService,
  );

  setUpAll(() {
    // Register fallback values for using mocktail in page tests
    final foodReference = CustomFoodReference(id: '', name: '');
    const sensitivityLevel = SensitivityLevel.none;
    final symptomType = SymptomType(id: '', name: '');
    final symptom = Symptom(symptomType: symptomType, severity: Severity.mild);
    final sensitivity = Sensitivity(level: sensitivityLevel, source: SensitivitySource.user);

    registerFallbackValue<BowelMovementEntryEvent>(BowelMovementEntryEventFake());
    registerFallbackValue<BowelMovementEntryState>(BowelMovementEntryLoading());

    registerFallbackValue<DiaryEvent>(DiaryEventFake());
    registerFallbackValue<DiaryState>(DiaryLoading());

    registerFallbackValue<FoodEvent>(FoodEventFake());
    registerFallbackValue<FoodState>(FoodsLoading());

    registerFallbackValue<FoodReference>(EdamamFoodReference(id: 'id', name: 'name'));
    registerFallbackValue<EdamamFoodReference>(EdamamFoodReference(id: 'id', name: 'name'));
    registerFallbackValue<CustomFoodReference>(CustomFoodReference(id: 'id', name: 'name'));

    registerFallbackValue<MealElement>(MealElement(id: '', foodReference: foodReference));

    registerFallbackValue<MealElementEvent>(MealElementEventFake());
    registerFallbackValue<MealElementState>(MealElementLoading());

    registerFallbackValue<MealEntryEvent>(MealEntryEventFake());
    registerFallbackValue<MealEntryState>(MealEntryLoading());

    registerFallbackValue<PantryEntry>(
        PantryEntry(userFoodDetailsId: '', foodReference: foodReference, sensitivity: sensitivity, notes: null));

    registerFallbackValue<PantryEvent>(PantryEventFake());
    registerFallbackValue<PantryState>(PantryLoading());

    registerFallbackValue<PantryEntryEvent>(PantryEntryEventFake());
    registerFallbackValue<PantryEntryState>(PantryEntryLoading());

    registerFallbackValue<PantrySortState>(PantrySortLoading(sort: PantrySort.alphabeticalAscending));

    registerFallbackValue<PantryFilterState>(PantryFilterLoading(filter: PantryFilter.all()));

    registerFallbackValue<SymptomEntryEvent>(SymptomEntryEventFake());
    registerFallbackValue<SymptomEntryState>(SymptomEntryLoading());

    registerFallbackValue<SymptomTypeEvent>(SymptomTypeEventFake());
    registerFallbackValue<SymptomTypeState>(SymptomTypesLoading());

    registerFallbackValue<SymptomEntry>(SymptomEntry(id: '', datetime: DateTime.now(), symptom: symptom));

    registerFallbackValue<UserFoodDetailsApi>(
        UserFoodDetailsApi(id: '', foodReference: foodReference, sensitivityLevel: sensitivityLevel));
  });

  setUp(() {
    // Reset analytics before each tests to correctly measure method calls
    mockito.reset(analyticsService);
    mockito.reset(crashlyticsService);
  });

  await testMain();
}
