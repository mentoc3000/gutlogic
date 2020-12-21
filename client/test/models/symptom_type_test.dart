import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/symptom_type.dart';
import 'package:test/test.dart';

void main() {
  group('SymptomType', () {
    test('constructs simple object', () {
      final symptomType = SymptomType(id: 'symptomType1', name: 'Pro-8');
      expect(symptomType.name, 'Pro-8');
    });

    test('is equatable', () {
      SymptomType constructSymptomType() => SymptomType(id: 'symptomType1', name: 'Pro-8');
      expect(constructSymptomType(), constructSymptomType());
    });

    test('is deserializable', () {
      final symptomTypeJson = {'id': 'id1', 'name': 'Pro-8'};
      final symptomType = serializers.deserializeWith(SymptomType.serializer, symptomTypeJson);
      expect(symptomType.name, 'Pro-8');
    });

    test('is serializable', () {
      final symptomType = SymptomType.fromBuilder((b) => b
        ..id = 'id1'
        ..name = 'Pro-8');
      expect(serializers.serialize(symptomType), {
        '\$': 'SymptomType',
        'id': 'id1',
        'name': 'Pro-8',
      });
    });

    test('has a search heading', () {
      final symptomType = SymptomType(id: 'symptomType1', name: 'Pro-8');
      expect(symptomType.searchHeading(), symptomType.name);
    });
  });
}
