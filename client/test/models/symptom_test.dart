import 'package:built_value/serializer.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:gutlogic/models/symptom.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:test/test.dart';

void main() {
  group('Symptom', () {
    test('constructs simple object', () {
      final symptomType = SymptomType(id: 'id', name: 'Gas');
      final symptom = Symptom(symptomType: symptomType, severity: Severity.moderate);
      expect(symptom.symptomType, symptomType);
      expect(symptom.severity, Severity.moderate);
    });

    test('build nested object', () {
      final symptom = Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Gas'
        ..severity = Severity.moderate);
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, Severity.moderate);
    });

    test('rebuild nested object', () {
      var symptom = Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Pain'
        ..severity = Severity.moderate);
      symptom = symptom.rebuild((b) => b..symptomType.name = 'Gas');
      expect(symptom.symptomType.name, 'Gas');
      expect(symptom.severity, Severity.moderate);
    });

    test('is equatable', () {
      Symptom constructSymptom() => Symptom.fromBuilder((b) => b
        ..symptomType.id = 'st1'
        ..symptomType.name = 'Gas'
        ..severity = Severity.intense);
      expect(constructSymptom(), constructSymptom());
    });

    test('is deserializable', () {
      final symptomJson = {
        'symptomType': {'id': 'id', 'name': 'Gas'},
        'severity': serializers.serialize(Severity.moderate, specifiedType: const FullType(Severity)),
      };
      final symptom = serializers.deserializeWith(Symptom.serializer, symptomJson)!;
      expect(symptom.symptomType.name, 'Gas');
    });

    test('is serializable', () {
      final symptomType = SymptomType(id: 'id', name: 'Gas');
      final symptom = Symptom.fromBuilder((b) => b
        ..symptomType = symptomType.toBuilder()
        ..severity = Severity.moderate);
      final symptomTypeJson = serializers.serialize(symptomType) as Map<String, dynamic>;
      expect(serializers.serialize(symptom), {
        '\$': 'Symptom',
        'symptomType': symptomTypeJson..remove('\$'),
        'severity': serializers.serializeWith(Severity.serializer, symptom.severity),
      });
    });
  });
}
