import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:test/test.dart';

void main() {
  group('Symptom', () {
    test('constructs simple object', () {
      final symptomType = SymptomType(id: 'id', name: 'Gas');
      final symptom = Symptom(symptomType: symptomType, severity: 2.1);
      expect(symptom.symptomType, symptomType);
      expect(symptom.severity, 2.1);
    });

    test('build nested object', () {
      final symptom = Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Gas'
        ..severity = 2.1);
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, 2.1);
    });

    test('rebuild nested object', () {
      var symptom = Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Pain'
        ..severity = 2.1);
      symptom = symptom.rebuild((b) => b..symptomType.name = 'Gas');
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, 2.1);
    });

    test('is equatable', () {
      Symptom constructSymptom() => Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Gas'
        ..severity = 3.4);
      expect(constructSymptom(), constructSymptom());
    });

    test('is deserializable', () {
      const symptomJson = {
        'symptomType': {'id': 'id', 'name': 'Gas'},
        'severity': 4.56,
      };
      final symptom = serializers.deserializeWith(Symptom.serializer, symptomJson);
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, 4.56);
    });

    test('is serializable', () {
      final symptomType = SymptomType(id: 'id', name: 'Gas');
      final symptom = Symptom.fromBuilder((b) => b
        ..symptomType = symptomType.toBuilder()
        ..severity = 2.1);
      final Map<String, dynamic> symptomTypeJson = serializers.serialize(symptomType);
      expect(serializers.serialize(symptom), {
        '\$': 'Symptom',
        'symptomType': symptomTypeJson..remove('\$'),
        'severity': symptom.severity,
      });
    });
  });
}
