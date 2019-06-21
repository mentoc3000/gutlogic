import 'package:test/test.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'package:gut_ai/models/symptom.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Symptom', () {
    test('constructs simple object', () {
      SymptomType symptomType = SymptomType.fromBuilder((b) => b..name = 'Gas');
      Symptom symptom = Symptom(symptomType: symptomType, severity: 2.1);
      expect(symptom.symptomType, symptomType);
      expect(symptom.severity, 2.1);
    });

    test('build nested object', () {
      Symptom symptom = Symptom.fromBuilder((b) => b
        ..symptomType.name = 'Gas'
        ..severity = 2.1);
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, 2.1);
    });

    test('is equatable', () {
      final constructSymptom = () => Symptom.fromBuilder((b) => b
        ..symptomType.name = 'Gas'
        ..severity = 3.4);
      expect(constructSymptom(), constructSymptom());
    });

    test('is deserializable', () {
      const Map<String, dynamic> symptomJson = {
        'symptomType': {'name': 'Gas'},
        'severity': 4.56,
      };
      Symptom symptom =
          serializers.deserializeWith(Symptom.serializer, symptomJson);
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, 4.56);
    });

    test('is serializable', () {
      SymptomType symptomType = SymptomType.fromBuilder((b) => b..name = 'Gas');
      Symptom symptom = Symptom.fromBuilder((b) => b
        ..symptomType = symptomType.toBuilder()
        ..severity = 2.1);
      Map<String, dynamic> symptomTypeJson = serializers.serialize(symptomType);
      expect(serializers.serialize(symptom), {
        "\$": "Symptom",
        'symptomType': symptomTypeJson..remove('\$'),
        'severity': symptom.severity,
      });
    });

    test('has a name', () {
      Symptom symptom = Symptom.fromBuilder((b) => b
        ..symptomType.name = 'Gas'
        ..severity = 3.4);
      expect(symptom.name(), 'Gas');
    });
  });
}
