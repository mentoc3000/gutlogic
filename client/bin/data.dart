import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/diary_entry/bowel_movement_entry.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/diary_entry/symptom_entry.dart';
import 'package:gutlogic/models/food/edamam_food.dart';
import 'package:gutlogic/models/food/ingredient.dart';
import 'package:gutlogic/models/food_group_entry.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant/intensity.dart';
import 'package:gutlogic/models/irritant/irritant.dart';
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
import 'package:gutlogic/resources/irritant_service.dart';
import 'package:gutlogic/util/date_time_ext.dart';
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

final irritants = [
  Irritant(name: 'Fructan', concentration: 0.05, dosePerServing: 0.5),
  Irritant(name: 'Fructose', concentration: 0.001, dosePerServing: 0.01),
  Irritant(name: 'GOS', concentration: 0.008, dosePerServing: 0.08),
  Irritant(name: 'Sorbitol', concentration: 0.025, dosePerServing: 0.25),
].build();

final elementaryFood = EdamamFood(
  id: 'broccoli',
  name: 'Broccoli',
  brand: null,
  measures: [Measure(unit: 'Oz')].build(),
  irritants: irritants,
);

final ingredients = [
  Ingredient(name: 'Water'),
  Ingredient(name: 'Potatoes'),
  Ingredient(name: 'Beef'),
  Ingredient(name: 'Carrots'),
  Ingredient(name: 'Tomato Puree'),
  Ingredient(name: 'Sweet Corn'),
  Ingredient(name: 'Diced Tomatoes'),
  Ingredient(name: 'Onion'),
  Ingredient(name: 'Celery'),
  Ingredient(name: 'Salt'),
  Ingredient(name: 'Garlic'),
  Ingredient(name: 'Thyme'),
].toBuiltList();
final ingredientIrritants = [
  [Irritant(name: 'Ingredient Irritant', concentration: 0.1, dosePerServing: 0.1)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.2, dosePerServing: 0.2)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.3, dosePerServing: 0.3)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.4, dosePerServing: 0.4)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.5, dosePerServing: 0.5)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.6, dosePerServing: 0.6)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.7, dosePerServing: 0.7)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.8, dosePerServing: 0.8)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 0.9, dosePerServing: 0.9)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 1.0, dosePerServing: 1.0)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 1.1, dosePerServing: 1.1)].toBuiltList(),
  [Irritant(name: 'Ingredient Irritant', concentration: 1.2, dosePerServing: 1.2)].toBuiltList(),
];
final ingredientIrritantMap = Map.fromIterables(ingredients, ingredientIrritants);
final ingredientDoses = ingredientIrritants.map(IrritantService.doseMap);
final ingredientDosesMap = Map.fromIterables(ingredients, ingredientDoses);
final ingredientDosesMaxIntensities = Map.fromIterables(ingredientDoses, [
  Intensity.none, // Water
  Intensity.none, // Potatoes
  Intensity.none, // Beef
  Intensity.trace, // Carrots
  Intensity.unknown, // Tomato Puree
  Intensity.high, // Corn
  Intensity.low, // Diced Tomatoes
  Intensity.high, // Onion
  Intensity.high, // Celery
  Intensity.none, // Salt
  Intensity.high, // Garlic
  Intensity.unknown, // Thyme
]);

final compoundFood = EdamamFood(
  id: 'stew',
  name: 'Beef Stew',
  ingredients: ingredients,
);

final mealElement = MealElement(
  id: 'mealElement4',
  foodReference: elementaryFood.toFoodReference(),
  quantity: Quantity.unweighed(amount: 1, unit: 'Oz'),
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
    MealElement(
      id: 'mealElement12',
      foodReference: CustomFoodReference(id: 'bread', name: 'Multi-Grain Bread'),
      quantity: Quantity.unweighed(amount: 2, unit: 'slice'),
    ),
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
      id: 'mealElement11',
      foodReference: CustomFoodReference(id: 'tomato', name: 'Tomato'),
      quantity: Quantity.unweighed(amount: 1, unit: 'slice'),
    ),
    mealElement,
    MealElement(
      id: 'mealElement7',
      foodReference: CustomFoodReference(id: 'milk shake', name: 'Milk Shake'),
      quantity: Quantity.unweighed(amount: 12, unit: 'oz'),
      notes: 'Chocolate',
    ),
  ].build(),
  notes: 'Quick stop for a sandwich.',
);

final mealEntry3 = MealEntry(
  id: 'meal3',
  datetime: todayAt(18, 52),
  mealElements: [
    MealElement(
      id: 'mealElement5',
      foodReference: CustomFoodReference(id: 'turkey', name: 'Steak'),
      quantity: Quantity.unweighed(amount: 5, unit: 'oz'),
    ),
    MealElement(
      id: 'mealElement6',
      foodReference: CustomFoodReference(id: 'lettuce', name: 'Potato'),
      quantity: Quantity.unweighed(amount: 2, unit: 'leaves'),
    ),
    MealElement(
      id: 'mealElement7',
      foodReference: CustomFoodReference(id: 'milk shake', name: 'Broccoli'),
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
final symptomEntry2 = SymptomEntry(
  id: 'symptom1',
  datetime: todayAt(14, 35),
  symptom: Symptom(symptomType: SymptomType(id: 'symptomType1', name: 'Cramps'), severity: Severity.intense),
  notes: 'Feels like a reaction to the bread.',
);

final diary = [
  mealEntry,
  bowelMovementEntry,
  mealEntry2,
  symptomEntry,
  symptomEntry2,
  mealEntry3,
].build();

final sensitivities = {
  mealEntry.mealElements[0].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry.mealElements[1].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry.mealElements[2].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[0].foodReference:
      Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
  mealEntry2.mealElements[1].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[2].foodReference:
      Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user),
  mealEntry2.mealElements[3].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry2.mealElements[4].foodReference: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
  mealEntry2.mealElements[5].foodReference:
      Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user),
  mealEntry3.mealElements[0].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry3.mealElements[1].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
  mealEntry3.mealElements[2].foodReference: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
};

final pantryEntry = PantryEntry(
  userFoodDetailsId: '1',
  foodReference: elementaryFood.toFoodReference(),
  sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
  notes: 'Makes me feel bloated the rest of the day.',
);

final pantryEntries = [
  PantryEntry(
    userFoodDetailsId: '2',
    foodReference: CustomFoodReference(id: '2', name: 'Pasta'),
    sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
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
    userFoodDetailsId: '4',
    foodReference: CustomFoodReference(id: '4', name: 'Multi-Grain Bread'),
    sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
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
    foodReference: CustomFoodReference(id: '3', name: 'Garlic'),
    sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Cherry'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Apple'),
    sensitivity: Sensitivity(level: SensitivityLevel.mild, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Almond'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Fig'),
    sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Plum'),
    sensitivity: Sensitivity(level: SensitivityLevel.severe, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Strawberry'),
    sensitivity: Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.user),
    notes: null,
  ),
  PantryEntry(
    userFoodDetailsId: '3',
    foodReference: CustomFoodReference(id: '3', name: 'Yoghurt'),
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
    foodReference: compoundFood.toFoodReference(),
    sensitivity: Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user),
    notes: null,
  ),
].build();

final foodGroupName = 'Vegetables';
final foodGroupNames = {foodGroupName, 'Fruits', 'Grains', 'Proteins', 'Dairy'}.build();

final vegetables = [
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_b1a90x2by6m8pnbsdfxnmascz2tc',
      name: 'Acorn Squash',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.052000000000000005}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_aneqha3aarf9vmawbdwibaf8jnus',
      name: 'Artichoke Heart',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.8160000000000001, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_brzhn72aca36jrbeufka9b1p6fic',
      name: 'Artichoke, Jerusalem',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 6.75, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_b7bgzddbqq26mia27xpv7acn083m', name: 'Asparagus'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.054, 'GOS': 0.0, 'Fructan': 1.5, 'Fructose': 0.24600000000000016}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_a8l38voaf1algubwcsji2a8z2yh3',
      name: 'Bean Sprout',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.010400000000000001, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bofj0lnbbcv11zblx10sob7clgvp', name: 'Beet'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0952, 'Fructan': 0.272, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_a8g63g7ak6bnmvbu7agxibp4a0dy',
      name: 'Bell Pepper, Green',
    ),
    doses: BuiltMap({'Sorbitol': 0.3145, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_a8g63g7ak6bnmvbu7agxibp4a0dy',
      name: 'Bell Pepper, Red',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bq7w3usaxapk30b8utp6lasy79lv',
      name: 'Bok Choy',
    ),
    doses: BuiltMap({'Sorbitol': 0.17, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_aahw0jha9f8337ajbopx9aec6z7i', name: 'Broccoli'),
    doses: BuiltMap({
      'Sorbitol': 0.28200000000000003,
      'Mannitol': 0.0,
      'GOS': 0.12219999999999999,
      'Fructan': 0.7426,
      'Fructose': 0.2256000000000001
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bkr6xbxbvl7pgua0vy4ibblf93qq',
      name: 'Brussels Sprouts',
    ),
    doses: BuiltMap({
      'Sorbitol': 0.3116,
      'Mannitol': 0.0,
      'GOS': 0.0,
      'Fructan': 2.2960000000000003,
      'Fructose': 0.19679999999999995
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_baga212bywb6n2as0ylgkaf8fcok',
      name: 'Butternut Squash',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.48, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.12}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_afb4o8kb767k0iapchxupaifxk1z', name: 'Cabbage'),
    doses: BuiltMap({'Sorbitol': 0.13160000000000002, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.4324, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_aqdc0pjbbr7wddbvgrka4bihwsm7',
      name: 'Cabbage, Savoy',
    ),
    doses: BuiltMap({
      'Sorbitol': 0.12219999999999999,
      'Mannitol': 0.0,
      'GOS': 0.0,
      'Fructan': 0.36660000000000004,
      'Fructose': 0.0
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_ai215e5b85pdh5ajd4aafa3w2zm8', name: 'Carrots'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0348, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_buqfaxubzh6hi5asev8a5aj9sr71', name: 'Cauliflower'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 3.9072, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.03959999999999999}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_aauwsy2b30wim3a7jsdwfbbfkyuu', name: 'Celeriac'),
    doses: BuiltMap({
      'Sorbitol': 0.0,
      'Mannitol': 0.07200000000000001,
      'GOS': 0.0,
      'Fructan': 0.0,
      'Fructose': 0.14400000000000002
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bffeoksbyyur8ja4da73ub2xs57g', name: 'Celery'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 2.413, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_btg1uzjak79lawbirsitkaeai60l', name: 'Chives'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.06}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bld46lwb614pf9awsxki0b3pbq2n',
      name: 'Corn, Sweet',
    ),
    doses: BuiltMap({'Sorbitol': 0.425, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bv7aggjag9rxsaatklqzobca5fzn', name: 'Cucumber'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.14079999999999993}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bwctyrwb3acpvdat4ef8gakhgad9', name: 'Daikon'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_ac9n68caswlpggbp7727varlyjk5', name: 'Eggplant'),
    doses: BuiltMap({'Sorbitol': 0.0451, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_a62ic8jbisg999a11qxfxaf5ibav', name: 'Endive'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.04}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_a4sdbkob8ixokpb07a42dbt3typw', name: 'Fennel'),
    doses: BuiltMap({
      'Sorbitol': 0.06860000000000001,
      'Mannitol': 0.1568,
      'GOS': 0.049,
      'Fructan': 0.15189999999999998,
      'Fructose': 0.049
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_b54ahckarp9qwwak6d1gobrmfxfd',
      name: 'Fennel Leaves',
    ),
    doses: BuiltMap({
      'Sorbitol': 0.13720000000000002,
      'Mannitol': 0.10289999999999999,
      'GOS': 0.0,
      'Fructan': 0.08330000000000001,
      'Fructose': 0.0
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_avtcmx6bgjv1jvay6s6stan8dnyp', name: 'Garlic'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.522, 'Fructose': 0.006}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bi2ki2xb5zmmvbaiwf7ztbgktzp6', name: 'Ginger'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0029999999999999975}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_aceucvpau4a8v6atkx5eabxyoqdn',
      name: 'Green Beans',
    ),
    doses: BuiltMap({
      'Sorbitol': 0.0935,
      'Mannitol': 0.060500000000000005,
      'GOS': 0.0,
      'Fructan': 0.0,
      'Fructose': 0.05500000000000005
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bbi35jtbjt7un9bsa2m7eazlsk91',
      name: 'Green Peas',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0085, 'Fructose': 0.2295}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_a27jevnb06c1m9ax7k41xbbcwcuo', name: 'Leek'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 5.893, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bf5fxtkbc9alwoajuvsi7amonr5w',
      name: 'Lettuce, Butter',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.11040000000000001}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_advhqk1a09o2noblosrg6a4z10xv',
      name: 'Lettuce, Iceberg',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.02299999999999998}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_ampdt7za0sr3pob8c1e0wb1uanyw',
      name: 'Lettuce, Romaine',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.09430000000000001}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bvlose6arfl26ra396sjrb7hetqh',
      name: 'Mushroom, Button',
    ),
    doses: BuiltMap({'Sorbitol': 0.0814, 'Mannitol': 1.9462, 'GOS': 0.0, 'Fructan': 0.1998, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_avlwv78af3cmk9akryrzjbp5sm4g',
      name: 'Navy Beans',
    ),
    doses: BuiltMap(
        {'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.94285, 'Fructan': 0.2249, 'Fructose': 0.25949999999999995}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_azzxfccb55c06lalc8vfobrxispc', name: 'Okra'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.081, 'Fructose': 0.075}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bmrvi4ob4binw9a5m7l07amlfcoy', name: 'Onion'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 1.008, 'Fructose': 0.15679999999999997}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_bmv8z27b1o25vcbu41ooyawd2zj4',
      name: 'Onion Powder',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.4392, 'Fructose': 0.022559999999999997}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_afr1xalbanh8elb1szv1nakwcj0o',
      name: 'Onion, Brown',
    ),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.336, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_admr9qdb3d66y9blt7afaazt0dbq', name: 'Parsnip'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_abiw5baauresjmb6xpap2bg3otzu', name: 'Potato'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_binrtnib8lnqofait7t9gacuadu0',
      name: 'Potato, Sweet',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.378, 'GOS': 0.0, 'Fructan': 0.028, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bs6xkukbtd85e7b2lh5zfazpe45y', name: 'Radish'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.002, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_a7d8j1ma2msbdlbqllxhfacln7y6', name: 'Rhubarb'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bn5prizbgsrr0tact46ataaj7b5p', name: 'Seaweed'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_bu2ver7a5f52dfap8q9f0bn085qb', name: 'Shallot'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 1.068}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_axypy6pakiktpcb6151czakqj1sd',
      name: 'Snow Peas',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.3712, 'GOS': 0.0, 'Fructan': 0.2048, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_aoceuc6bshdej1bbsdammbnj6l6o', name: 'Spinach'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.05600000000000001, 'Fructose': 0.016}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_aylvcuubuoxe1nawqrmnjbqjplem', name: 'Tamarillo'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.04399999999999996}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_b1iysizbar4mzealfqj5pb0892mf', name: 'Taro'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_a6k79rrahp8fe2b26zussa3wtkqh', name: 'Tomato'),
    doses: BuiltMap({
      'Sorbitol': 0.0,
      'Mannitol': 0.0,
      'GOS': 0.0,
      'Fructan': 0.049499999999999995,
      'Fructose': 0.16500000000000006
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_a30b0hpbvavginafe0tocbf6ymje',
      name: 'Tomato, Cherry',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.16499999999999995}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_ab8jymba5i5xv3apgymg7a90bxb5',
      name: 'Tomato, Roma',
    ),
    doses: BuiltMap({
      'Sorbitol': 0.0,
      'Mannitol': 0.0,
      'GOS': 0.0,
      'Fructan': 0.044000000000000004,
      'Fructose': 0.05500000000000005
    }),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_b18l5bgbk88v6zawje5rybd5ngk1',
      name: 'Tomato, Sun Dried',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.504}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_buj0e74bxco8n0betbsnzayddt6a', name: 'Turnip'),
    doses: BuiltMap({'Sorbitol': 0.14300000000000002, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_b18ctxdbw2ktnpbejotkwbnalyrj', name: 'Wasabi'),
    doses: BuiltMap({'Sorbitol': 0.555, 'Mannitol': 0.015, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(
      id: 'food_au2sbdxab6gazqbg40zk8alrx2dp',
      name: 'Water Chestnuts',
    ),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.0, 'Fructose': 0.0}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_b6x8exdbm5bwzybi8kcbybyfj407', name: 'Yam'),
    doses: BuiltMap({'GOS': 0.0, 'Fructan': 0.022000000000000002}),
  ),
  FoodGroupEntry(
    foodRef: EdamamFoodReference(id: 'food_avpihljbuwpd8ibbmahcabaros5s', name: 'Zucchini'),
    doses: BuiltMap({'Sorbitol': 0.0, 'Mannitol': 0.0, 'GOS': 0.0, 'Fructan': 0.1653, 'Fructose': 0.17670000000000002}),
  )
].toBuiltSet();
final vegetableListSorted = vegetables.toList()..sort((a, b) => a.foodRef.name.compareTo(b.foodRef.name));
final vegetableDoses = vegetables.map((p0) => p0.doses);
final vegetableDosesMaxIntensities = Map.fromIterables(vegetableDoses, [
  Intensity.low, // Acorn Squash
  Intensity.high, // Artichoke Heart
  Intensity.high, // Artichoke, Jerusalem
  Intensity.high, // Asparagus
  Intensity.trace, // Bean Sprout
  Intensity.medium, // Beet
  Intensity.medium, // Bell Pepper, Green
  Intensity.low, // Bell Pepper, Red
  Intensity.low, // Bok Choy
  Intensity.high, // Broccoli
  Intensity.high, // Brussels Sprouts
  Intensity.high, // Butternut Squahs
  Intensity.high, // Cabbage
  Intensity.high, // Cabbage, Savoy
  Intensity.trace, // Carrots
  Intensity.high, // Cauliflower
  Intensity.medium, // Celeriac
  Intensity.high, // Celery
  Intensity.low, // Chives
  Intensity.high, // Corn, Sweet
  Intensity.none, // Cucumber
  Intensity.none, // Daikon
  Intensity.low, // Eggplant
  Intensity.trace, // Endive
  Intensity.medium, // Fennel
  Intensity.low, // Fennel Leaves
  Intensity.high, // Garlic
  Intensity.low, // Ginger
  Intensity.low, // Green Beans
  Intensity.medium, // Green Peas
  Intensity.high, // Leek
  Intensity.medium, // Lettuce, Butter
  Intensity.low, // Lettuce, Iceberg
  Intensity.medium, // Lettuce, Romaine
  Intensity.high, // Mushroom, Button
  Intensity.high, // Navy Beans
  Intensity.low, // Okra
  Intensity.high, // Onion
  Intensity.high, // Onion Powder
  Intensity.high, // Onion, Brown
  Intensity.none, // Parsnip
  Intensity.none, // Potato
  Intensity.high, // Potato, Sweet
  Intensity.low, // Radish
  Intensity.none, // Rhubarb
  Intensity.none, // Seaweed
  Intensity.high, // Shallot
  Intensity.high, // Snow Peas
  Intensity.low, // Spinach
  Intensity.medium, // Tamarillo
  Intensity.none, // Taro
  Intensity.low, // Tomato
  Intensity.medium, // Tomato, Cherry
  Intensity.low, // Tomato, Roma
  Intensity.high, // Tomato, Sun Dried
  Intensity.low, // Turnip
  Intensity.high, // Wasabi
  Intensity.none, // Water Chestnut
  Intensity.low, // Yam
  Intensity.medium, // Zucchini
]);
final dosesMaxIntensities = Map.from(vegetableDosesMaxIntensities)..addAll(ingredientDosesMaxIntensities);
final intensityThresholds = {
  'Mannitol': [0.0, 0.2, 0.35].build(),
  'GOS': [0.0, 0.15, 0.4].build(),
  'Lactose': [0.0, 1.20, 5.0].build(),
  'Fructan': [0.0, 0.1, 0.3].build(),
  'Sorbitol': [0.0, 0.2, 0.35].build(),
  'Fructose': [0.0, 0.03, 0.2].build(),
};

final diaryStreak = BuiltMap<DateTime, int>({
  DateTime.now(): 3,
  DateTime.now().subtractDays(1): 2,
  DateTime.now().subtractDays(2): 1,
  DateTime.now().subtractDays(3): 0,
  DateTime.now().subtractDays(4): 2,
});

final foodCountByIrritant = BuiltMap<String, BuiltMap<SensitivityLevel, int>>({
  'Fructan': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 1,
    SensitivityLevel.mild: 2,
    SensitivityLevel.moderate: 4,
    SensitivityLevel.severe: 6,
    SensitivityLevel.unknown: 1,
  }),
  'Fructose': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 6,
    SensitivityLevel.mild: 2,
    SensitivityLevel.moderate: 2,
    SensitivityLevel.severe: 0,
    SensitivityLevel.unknown: 1,
  }),
  'Sorbitol': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 4,
    SensitivityLevel.mild: 5,
    SensitivityLevel.moderate: 2,
    SensitivityLevel.severe: 2,
    SensitivityLevel.unknown: 2,
  }),
  'Mannitol': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 7,
    SensitivityLevel.mild: 3,
    SensitivityLevel.moderate: 1,
    SensitivityLevel.severe: 0,
    SensitivityLevel.unknown: 1,
  }),
  ' Lactose': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 5,
    SensitivityLevel.mild: 4,
    SensitivityLevel.moderate: 3,
    SensitivityLevel.severe: 2,
    SensitivityLevel.unknown: 1,
  }),
  'GOS': BuiltMap<SensitivityLevel, int>({
    SensitivityLevel.none: 2,
    SensitivityLevel.mild: 2,
    SensitivityLevel.moderate: 3,
    SensitivityLevel.severe: 3,
    SensitivityLevel.unknown: 1,
  }),
});

final severities = [
  Severity.moderate,
  null,
  Severity.severe,
  Severity.moderate,
  Severity.intense,
  Severity.mild,
  null,
];
final now = DateTime.now();
final daysCount = severities.length;
final dates = Iterable.generate(daysCount, (index) => now.subtract(Duration(days: daysCount - index - 1)));
final recentSeverities = BuiltMap<DateTime, Severity?>(Map.fromIterables(dates, severities));

final symptomTypeCount = BuiltMap<SymptomType, int>({
  SymptomType(id: 'id', name: 'Bloating'): 10,
  SymptomType(id: 'id', name: 'Diarrhea'): 4,
  SymptomType(id: 'id', name: 'Cramping'): 2,
  SymptomType(id: 'id', name: 'Pain'): 1,
});
