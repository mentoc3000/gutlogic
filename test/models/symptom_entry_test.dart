import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/diary_entry.dart';
import 'package:gut_ai/models/symptom.dart';
import 'package:gut_ai/models/symptom_type.dart';

void main() {
  group('SymptomEntry', () {
    test('constructs empty object', () {
      SymptomEntry mealEntry = SymptomEntry();
      expect(mealEntry.symptom, Symptom());
      expect(mealEntry.dateTime, null);
    });

    test('constructs simple object', () {
      Symptom symptom = Symptom();
      DateTime dateTime = DateTime.now();
      SymptomEntry mealEntry = SymptomEntry(
        symptom: symptom,
        dateTime: dateTime,
      );
      expect(mealEntry.symptom, symptom);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is equatable', () {
      final constructSymptom = () => SymptomEntry(
            symptom: Symptom(),
            dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
          );
      expect(constructSymptom(), constructSymptom());
    });

    test('is deserializable', () {
      Symptom symptom = Symptom(
        symptomType: SymptomType(name: 'Gas'),
        severity: 3.4,
      );
      DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(0);
      Map<String, dynamic> mealJson = {
        'symptom': symptom.toJson(),
        'dateTime': dateTime.toIso8601String(),
      };
      SymptomEntry mealEntry = SymptomEntry.fromJson(mealJson);
      expect(mealEntry.symptom, symptom);
      expect(mealEntry.dateTime, dateTime);
    });

    test('is serializable', () {
      SymptomEntry mealEntry = SymptomEntry(
        symptom: Symptom(
          symptomType: SymptomType(name: 'Gas'),
          severity: 3.4,
        ),
        dateTime: DateTime.fromMicrosecondsSinceEpoch(0),
      );
      expect(mealEntry.toJson(), {
        'symptom': mealEntry.symptom.toJson(),
        'dateTime': DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
      });
    });
  });
}
