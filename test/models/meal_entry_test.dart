import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/meal.dart';

void main() {
  group('MealEntry', () {
    test('constructs empty object', () {
      MealEntry mealEntry = MealEntry();
      expect(mealEntry.meal, Meal());
      expect(mealEntry.dateTime, null);
    });

    test('constructs simple object', () {
      Meal meal = Meal();
      DateTime dateTime = DateTime.now();
      MealEntry mealEntry = MealEntry(
        meal: meal,
        dateTime: dateTime,
      );
      expect(mealEntry.meal, meal);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is equatable', () {
      final constructMeal = () => MealEntry(
            meal: Meal(),
            dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
          );
      expect(constructMeal(), constructMeal());
    });

    test('is deserializable', () {
      Meal meal = Meal(name: 'Breakfast');
      DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(0);
      Map<String, dynamic> mealJson = {
        'meal': meal.toJson(),
        'dateTime': dateTime.toIso8601String(),
      };
      MealEntry mealEntry = MealEntry.fromJson(mealJson);
      expect(mealEntry.meal, meal);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is serializable', () {
      MealEntry mealEntry = MealEntry(
        meal: Meal(name: 'Breakfast'),
        dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
      );
      expect(mealEntry.toJson(), {
        'meal': {
          'name': 'Breakfast',
          'ingredients': [],
        },
        'dateTime': DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
      });
    });
  });
}
