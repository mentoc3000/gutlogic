import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'package:gut_ai/models/symptom.dart';

void main() {
  group('Symptom', () {
    test('constructs empty object', () {
      Symptom symptomType = Symptom();
      expect(symptomType.symptomType, null);
      expect(symptomType.severity, null);
    });

    test('constructs simple object', () {
      SymptomType symptomType = SymptomType(name: 'Gas');
      Symptom symptom = Symptom(
        symptomType: symptomType,
        severity: 2.1,
      );
      expect(symptom.symptomType, symptomType);
      expect(symptom.severity, 2.1);
    });

    test('is equatable', () {
      final constructSymptom = () => Symptom(
            symptomType: SymptomType(),
            severity: 3.4,
          );
      expect(constructSymptom(), constructSymptom());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> symptomJson = {
        'symptomType': {'name': 'Gas'},
        'severity': 4.56,
      };
      Symptom symptom = Symptom.fromJson(symptomJson);
      expect(symptom.symptomType, SymptomType(name: 'Gas'));
      expect(symptom.severity, 4.56);
    });

    test('is serializable', () {
      SymptomType symptomType = SymptomType(name: 'Gas');
      Symptom symptom = Symptom(
        symptomType: symptomType,
        severity: 3,
      );
      expect(symptom.toJson(), {
        'symptomType': symptomType.toJson(),
        'severity': 3,
      });
    });
  });
}
