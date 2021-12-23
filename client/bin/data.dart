import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth_provider.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

TZDateTime todayAt(int hour, int minute) {
  // Today
  initializeTimeZones();
  final location = getLocation('America/Detroit');
  setLocalLocation(location);
  final now = TZDateTime.now(location);
  return TZDateTime(location, now.year, now.month, now.day, hour, minute);
}

final user = ApplicationUser(
  id: 'id',
  email: 'email',
  verified: true,
  consented: true,
  providers: [AuthProvider.password].build(),
);

final food = EdamamFood(
  id: 'bread',
  name: 'Multi-Grain Bread',
  brand: null,
  measures: [Measure(unit: 'Slice')].build(),
  // irritants: ['Fructose', 'Glucose', 'Oligosaccharides', 'Raffinose', 'Total Fructan']
  //     .map((n) => Irritant(name: n))
  //     .toBuiltList(),
);

final mealElement = MealElement(
  id: 'mealElement4',
  foodReference: food.toFoodReference(),
  quantity: Quantity.unweighed(amount: 2, unit: 'Slice'),
);

final mealEntry = MealEntry(
  id: 'meal1',
  datetime: todayAt(7, 21),
  mealElements: [
    MealElement(
      id: 'mealElement2',
      foodReference: CustomFoodReference(id: 'Oatmeal', name: 'Oatmeal'),
      quantity: Quantity.unweighed(amount: 1, unit: 'cup'),
    ),
    MealElement(
      id: 'mealElement3',
      foodReference: CustomFoodReference(id: 'banana', name: 'Banana'),
      quantity: Quantity.unweighed(amount: 1, unit: 'each'),
    ),
    MealElement(
      id: 'mealElement1',
      foodReference: CustomFoodReference(id: 'orange juice', name: 'Orange Juice'),
      quantity: Quantity.unweighed(amount: 6, unit: 'oz'),
    ),
  ].build(),
);

final mealEntry2 = MealEntry(
  id: 'meal2',
  datetime: todayAt(12, 38),
  mealElements: [
    mealElement,
    MealElement(
      id: 'mealElement5',
      foodReference: CustomFoodReference(id: 'turkey', name: 'Turkey'),
      quantity: Quantity.unweighed(amount: 5, unit: 'oz'),
    ),
    MealElement(
      id: 'mealElement6',
      foodReference: CustomFoodReference(id: 'lettuce', name: 'Lettuce'),
      quantity: Quantity.unweighed(amount: 2, unit: 'leaves'),
    ),
    MealElement(
      id: 'mealElement7',
      foodReference: CustomFoodReference(id: 'milk shake', name: 'Milk Shake'),
      quantity: Quantity.unweighed(amount: 12, unit: 'oz'),
      notes: 'Chocolate',
    ),
  ].build(),
  notes: 'Quick stop for fast food.',
);

final bowelMovementEntry = BowelMovementEntry(
  id: 'bm1',
  datetime: todayAt(9, 47),
  bowelMovement: BowelMovement(volume: 3, type: 4),
);

final symptomEntry = SymptomEntry(
  id: 'symptom1',
  datetime: todayAt(14, 3),
  symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: 'Bloated'), severity: Severity.intense),
  notes: 'Feels like a reaction to the bread.',
);

final diary = [
  mealEntry,
  bowelMovementEntry,
  mealEntry2,
  symptomEntry,
].build();

final sensitivities = {
  mealEntry.mealElements[0].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry.mealElements[1].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry.mealElements[2].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[0].foodReference:
      Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
  mealEntry2.mealElements[1].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[2].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[3].foodReference:
      Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user),
};

final pantryEntry = PantryEntry(
  userFoodDetailsId: '1',
  foodReference: food.toFoodReference(),
  sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
  notes: 'Makes me feel bloated the rest of the day.',
);

final pantryEntries = [
  PantryEntry(
    userFoodDetailsId: '2',
    foodReference: CustomFoodReference(id: '2', name: 'Pasta'),
    sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
    notes: null,
  ),
  pantryEntry,
  PantryEntry(
    userFoodDetailsId: '5',
    foodReference: CustomFoodReference(id: '5', name: 'Pear'),
    sensitivity: Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '6',
    foodReference: CustomFoodReference(id: '6', name: 'Cola'),
    sensitivity: Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '4',
    foodReference: CustomFoodReference(id: '4', name: 'Onion'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Orange Juice'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Banana'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Oatmeal'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
].build();
