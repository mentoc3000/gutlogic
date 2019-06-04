import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('SymptomType', () {
    test('constructs simple object', () {
      SymptomType symptomType = SymptomType((b) => b..name = 'Pro-8');
      expect(symptomType.name, 'Pro-8');
    });

    test('is equatable', () {
      final constructSymptomType = () => SymptomType((b) => b..name = 'Pro-8');
      expect(constructSymptomType(), constructSymptomType());
    });

    test('is deserializable', () {
      Map<String, dynamic> symptomTypeJson = {"name": "Pro-8"};
      SymptomType symptomType =
          serializers.deserializeWith(SymptomType.serializer, symptomTypeJson);
      expect(symptomType.name, 'Pro-8');
    });

    test('is serializable', () {
      SymptomType symptomType = SymptomType((b) => b..name = 'Pro-8');
      expect(serializers.serialize(symptomType), {
        "\$": "SymptomType",
        "name": "Pro-8",
      });
    });

    test('has a search heading', () {
      SymptomType symptomType = SymptomType((b) => b..name = 'Pro-8');
      expect(symptomType.searchHeading(), symptomType.name);
    });
  });
}
