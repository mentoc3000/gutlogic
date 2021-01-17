import 'package:built_value/serializer.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/severity.dart';
import 'package:test/test.dart';

void main() {
  group('Severity', () {
    test('constructs enums', () {
      Severity.mild;
      Severity.moderate;
      Severity.intense;
      Severity.severe;
    });

    test('is deserializable', () {
      expect(serializers.deserializeWith(Severity.serializer, 0), Severity.mild);
      expect(serializers.deserializeWith(Severity.serializer, 1), Severity.mild);
      expect(serializers.deserializeWith(Severity.serializer, 2), Severity.moderate);
      expect(serializers.deserializeWith(Severity.serializer, 2.3), Severity.moderate);
      expect(serializers.deserializeWith(Severity.serializer, 2.5), Severity.intense);
      expect(serializers.deserializeWith(Severity.serializer, 3), Severity.intense);
      expect(serializers.deserializeWith(Severity.serializer, 4), Severity.severe);
      expect(serializers.deserializeWith(Severity.serializer, 5), Severity.severe);
    });

    test('is serializable', () {
      expect(serializers.serialize(Severity.mild, specifiedType: const FullType(Severity)), 1);
      expect(serializers.serialize(Severity.moderate, specifiedType: const FullType(Severity)), 2);
      expect(serializers.serialize(Severity.intense, specifiedType: const FullType(Severity)), 3);
      expect(serializers.serialize(Severity.severe, specifiedType: const FullType(Severity)), 4);
    });
  });
}
