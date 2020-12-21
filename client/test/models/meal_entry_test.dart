import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gutlogic/models/diary_entry/meal_entry.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Meal Entry', () {
    test('is serializable', () {
      const id = 'id';
      final datetime = DateTime(2019, 3, 15, 4, 24, 37).toUtc();
      final foodReference = CustomFoodReference(id: '234', name: 'Buns');
      final mealElements = BuiltList<MealElement>([
        MealElement.fromBuilder((b) => b
          ..id = '$id#mealElement1'
          ..foodReference = foodReference
          ..quantity.amount = 1.2
          ..quantity.unit = 'slices'),
      ]);
      final mealEntry = MealEntry.fromBuilder((b) => b
        ..id = id
        ..datetime = datetime
        ..mealElements = mealElements.toBuilder()
        ..notes = 'Tasty!');
      expect(serializers.serialize(mealEntry), {
        '\$': 'MealEntry',
        'id': id,
        'datetime': Timestamp.fromDate(datetime),
        'mealElements': mealElements.map((i) {
          final Map<String, dynamic> irritantJson = serializers.serialize(i);
          return irritantJson..remove('\$');
        }).toList(),
        'notes': mealEntry.notes,
      });
    });

    test('is deserializable', () {
      const id = 'id';
      final datetime = DateTime(2019, 3, 15, 4, 24, 37).toUtc();
      final mealEntryJson = {
        'id': id,
        'datetime': Timestamp.fromDate(datetime),
        'mealElements': [
          {
            'id': '$id#mealElement1',
            'foodReference': {
              '\$': 'CustomFoodReference',
              'id': '5',
              'name': 'Bread',
            },
            'quantity': {'amount': 1.2, 'unit': 'Slices'},
          },
        ],
        'notes': 'Tasty!'
      };
      final mealEntry = serializers.deserializeWith(MealEntry.serializer, mealEntryJson);
      expect(mealEntry.mealElements[0].foodReference.name, 'Bread');
      expect(mealEntry.notes, mealEntryJson['notes']);
      expect(mealEntry.datetime, datetime);
    });

    test('is deserializable with extra key/value pairs', () {
      const id = 'id';
      final datetime = DateTime(2019, 3, 15, 4, 24, 37).toUtc();
      final mealEntryJson = {
        'id': id,
        'type': 'MEAL_ENTRY',
        'datetime': Timestamp.fromDate(datetime),
        'mealElements': [
          {
            'id': '$id#mealElement1',
            'foodReference': {
              '\$': 'CustomFoodReference',
              'id': '5',
              'name': 'Bread',
            },
            'quantity': {'amount': 1.2, 'unit': 'Slices'},
          },
        ],
        'notes': 'Tasty!'
      };
      final mealEntry = serializers.deserializeWith(MealEntry.serializer, mealEntryJson);
      expect(mealEntry.mealElements[0].foodReference.name, 'Bread');
      expect(mealEntry.notes, mealEntryJson['notes']);
      expect(mealEntry.datetime, datetime);
    });
  });
}
