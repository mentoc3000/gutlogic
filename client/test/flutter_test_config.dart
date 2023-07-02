import 'dart:async';

import 'package:gutlogic/blocs/bowel_movement_entry/bowel_movement_entry.dart';
import 'package:gutlogic/blocs/diary/diary.dart';
import 'package:gutlogic/blocs/food_search/food_search.dart';
import 'package:gutlogic/blocs/meal_element/meal_element.dart';
import 'package:gutlogic/blocs/meal_entry/meal_entry.dart';
import 'package:gutlogic/blocs/pantry/pantry.dart';
import 'package:gutlogic/blocs/pantry_entry/pantry_entry.dart';
import 'package:gutlogic/blocs/pantry_sort/pantry_sort.dart';
import 'package:gutlogic/blocs/foods_suggestion/foods_suggestion.dart';
import 'package:gutlogic/blocs/symptom_entry/symptom_entry.dart';
import 'package:gutlogic/blocs/symptom_type/symptom_type.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/pantry/pantry_sort.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:gutlogic/models/user_food_details_api.dart';
import 'package:gutlogic/resources/firebase/analytics_service.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Use shared preferences version from in app review package
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'flutter_test_config.mocks.dart';

class BowelMovementEntryEventFake extends Fake implements BowelMovementEntryEvent {}

class DiaryEventFake extends Fake implements DiaryEvent {}

class FoodEventFake extends Fake implements FoodSearchEvent {}

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

  setUpAll(() {
    // Initialize shared preferences to something to allow access to SharedPreferences from app review plugin
    SharedPreferences.setMockInitialValues({});

    // Register fallback values for using mocktail in page tests
    final foodReference = CustomFoodReference(id: '', name: '');
    const sensitivityLevel = SensitivityLevel.none;
    final symptomType = SymptomType(id: '', name: '');
    final symptom = Symptom(symptomType: symptomType, severity: Severity.mild);
    final sensitivity = Sensitivity(level: sensitivityLevel, source: SensitivitySource.user);

    registerFallbackValue(BowelMovementEntryEventFake());
    registerFallbackValue(BowelMovementEntryLoading());

    registerFallbackValue(DiaryEventFake());
    registerFallbackValue(DiaryLoading());

    registerFallbackValue(FoodEventFake());
    registerFallbackValue(FoodSearchLoading());

    registerFallbackValue(EdamamFood(id: 'id', name: 'name'));
    registerFallbackValue(CustomFood(id: 'id', name: 'name'));

    registerFallbackValue(EdamamFoodReference(id: 'id', name: 'name'));
    registerFallbackValue(EdamamFoodReference(id: 'id', name: 'name'));
    registerFallbackValue(CustomFoodReference(id: 'id', name: 'name'));

    registerFallbackValue(MealElement(id: '', foodReference: foodReference));

    registerFallbackValue(MealElementEventFake());
    registerFallbackValue(MealElementLoading());

    registerFallbackValue(MealEntryEventFake());
    registerFallbackValue(MealEntryLoading());

    registerFallbackValue(
        PantryEntry(userFoodDetailsId: '', foodReference: foodReference, sensitivity: sensitivity, notes: null));

    registerFallbackValue(PantryEventFake());
    registerFallbackValue(PantryLoading());

    registerFallbackValue(PantryEntryEventFake());
    registerFallbackValue(PantryEntryLoading(foodName: ''));

    registerFallbackValue(PantrySortLoading(sort: PantrySort.alphabeticalAscending));

    registerFallbackValue(SymptomEntryEventFake());
    registerFallbackValue(SymptomEntryLoading());

    registerFallbackValue(const FoodsSuggestionLoading());

    registerFallbackValue(SymptomTypeEventFake());
    registerFallbackValue(SymptomTypesLoading());

    registerFallbackValue(SymptomEntry(id: '', datetime: DateTime.now(), symptom: symptom));

    registerFallbackValue(UserFoodDetailsApi(id: '', foodReference: foodReference, sensitivityLevel: sensitivityLevel));
  });

  setUp(() {
    // Reset analytics before each tests to correctly measure method calls
    mockito.reset(analyticsService);
    mockito.reset(crashlyticsService);
  });

  await testMain();
}
