import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/bowel_movement.dart';

void main() {
  group('BowelMovementEntry', () {
    test('constructs empty object', () {
      BowelMovementEntry mealEntry = BowelMovementEntry();
      expect(mealEntry.bowelMovement, BowelMovement());
      expect(mealEntry.dateTime, null);
    });

    test('constructs simple object', () {
      BowelMovement bowelMovement = BowelMovement();
      DateTime dateTime = DateTime.now();
      BowelMovementEntry mealEntry = BowelMovementEntry(
        bowelMovement: bowelMovement,
        dateTime: dateTime,
      );
      expect(mealEntry.bowelMovement, bowelMovement);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is equatable', () {
      final constructBowelMovement = () => BowelMovementEntry(
            bowelMovement: BowelMovement(),
            dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
          );
      expect(constructBowelMovement(), constructBowelMovement());
    });

    test('is deserializable', () {
      BowelMovement bowelMovement = BowelMovement(type: 3, volume: 4);
      DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(0);
      Map<String, dynamic> mealJson = {
        'bowelMovement': bowelMovement.toJson(),
        'dateTime': dateTime.toIso8601String(),
      };
      BowelMovementEntry mealEntry = BowelMovementEntry.fromJson(mealJson);
      expect(mealEntry.bowelMovement, bowelMovement);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is serializable', () {
      BowelMovementEntry bmEntry = BowelMovementEntry(
        bowelMovement: BowelMovement(type: 3, volume: 4),
        dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
      );
      expect(bmEntry.toJson(), {
        'bowelMovement': bmEntry.bowelMovement.toJson(),
        'dateTime': DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
      });
    });
  });
}
