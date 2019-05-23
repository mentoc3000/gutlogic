import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/symptom_type.dart';

void main() {
  group('SymptomType', () {
    test('constructs empty object', () {
      SymptomType symptomType = SymptomType();
      expect(symptomType.name, null);
    });

    test('constructs simple object', () {
      SymptomType symptomType = SymptomType(name: 'Gas');
      expect(symptomType.name, 'Gas');
    });

    test('is equatable', () {
      final constructSymptomType = () => SymptomType(name: 'Gas');
      expect(constructSymptomType(), constructSymptomType());
    });

    test('is deserializable', () {
      const Map<String, dynamic> medicineJson = {
        'name': 'Gas',
      };
      SymptomType symptomType = SymptomType.fromJson(medicineJson);
      expect(symptomType.name, 'Gas');
    });

    test('is serializable', () {
      SymptomType symptomType = SymptomType(name: 'Gas');
      expect(symptomType.toJson(), {'name': 'Gas'});
    });
  });
}
