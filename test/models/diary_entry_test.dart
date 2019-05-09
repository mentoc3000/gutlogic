import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/meal.dart';

void main() {
  group('Diary Entry', () {
    group('Meal Entry', () {
      test('default constructor should create empty meal', () {
        MealEntry mealEntry = MealEntry();
        expect(mealEntry.dateTime, null);
      });
    });
  });
}
