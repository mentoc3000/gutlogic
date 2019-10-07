import 'package:test/test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/meal.dart';
import 'package:gut_ai/models/ingredient.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Diary Entry', () {
    test('initial datetime is now', () {
      DateTime before = DateTime.now();
      MealEntry mealEntry = MealEntry.newEntry('', '');
      DateTime after = DateTime.now();
      expect(mealEntry.dateTime.isBefore(after), true);
      expect(mealEntry.dateTime.isAfter(before), true);
    });

    test('is serializable', () {
      String id = 'id';
      String userId = 'userId';
      DateTime dateTime = DateTime.utc(2019, 3, 15, 4, 24, 37);
      BuiltList<Ingredient> ingredients = BuiltList<Ingredient>([
        Ingredient.fromBuilder((b) => b
          ..food.name = 'Fructan'
          ..quantity.amount = 1.2
          ..quantity.unit = 'slices'),
      ]);
      Meal meal = Meal.fromBuilder((b) => b..ingredients = ingredients.toBuilder());
      Map<String,dynamic> mealJson = serializers.serialize(meal);
      MealEntry mealEntry = MealEntry.fromBuilder((b) => b
        ..id = id
        ..userId = userId
        ..creationDate = dateTime
        ..modificationDate = dateTime
        ..dateTime = dateTime
        ..meal = meal.toBuilder()
        ..notes = 'Tasty!');
      expect(serializers.serialize(mealEntry), {
        '\$': 'MealEntry',
        'id': id,
        'userId': userId,
        'creationDate': dateTime.microsecondsSinceEpoch,
        'modificationDate': dateTime.microsecondsSinceEpoch,
        'dateTime': dateTime.microsecondsSinceEpoch,
        'meal': mealJson..remove('\$'),
        'notes': mealEntry.notes,
      });
    });

    test('is deserializable', () {
      String id = 'id';
      String userId = 'userId';
      DateTime dateTime = DateTime.utc(2019, 3, 15, 4, 24, 37);
      Map<String, dynamic> mealEntryJson = {
        'id': id,
        'userId': userId,
        'creationDate': dateTime.microsecondsSinceEpoch,
        'modificationDate': dateTime.microsecondsSinceEpoch,
        'dateTime': dateTime.microsecondsSinceEpoch,
        'meal': {
          'ingredients': [
            {
              'food': {'name': 'Bread'},
              'quantity': {'amount': 1.2, 'unit': 'Slices'},
            },
          ],
        },
        'notes': 'Tasty!',
      };
      MealEntry mealEntry =
          serializers.deserializeWith(MealEntry.serializer, mealEntryJson);
      expect(mealEntry.meal.ingredients[0].food.name, 'Bread');
      expect(mealEntry.notes, mealEntryJson['notes']);
      expect(mealEntry.dateTime, dateTime);
    });
  });
}
