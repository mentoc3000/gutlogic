import 'package:built_value/serializer.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:test/test.dart';

void main() {
  group('Sensitivity', () {
    test('constructs enums', () {
      Sensitivity.unknown;
      Sensitivity.none;
      Sensitivity.mild;
      Sensitivity.moderate;
      Sensitivity.severe;
    });

    test('is deserializable', () {
      expect(serializers.deserializeWith(Sensitivity.serializer, -1), Sensitivity.unknown);
      expect(serializers.deserializeWith(Sensitivity.serializer, 0), Sensitivity.none);
      expect(serializers.deserializeWith(Sensitivity.serializer, 1), Sensitivity.mild);
      expect(serializers.deserializeWith(Sensitivity.serializer, 1.3), Sensitivity.mild);
      expect(serializers.deserializeWith(Sensitivity.serializer, 1.5), Sensitivity.moderate);
      expect(serializers.deserializeWith(Sensitivity.serializer, 2), Sensitivity.moderate);
      expect(serializers.deserializeWith(Sensitivity.serializer, 3), Sensitivity.severe);
      expect(serializers.deserializeWith(Sensitivity.serializer, 4), Sensitivity.severe);
    });

    test('is serializable', () {
      expect(serializers.serialize(Sensitivity.unknown, specifiedType: const FullType(Sensitivity)), -1);
      expect(serializers.serialize(Sensitivity.none, specifiedType: const FullType(Sensitivity)), 0);
      expect(serializers.serialize(Sensitivity.mild, specifiedType: const FullType(Sensitivity)), 1);
      expect(serializers.serialize(Sensitivity.moderate, specifiedType: const FullType(Sensitivity)), 2);
      expect(serializers.serialize(Sensitivity.severe, specifiedType: const FullType(Sensitivity)), 3);
    });
  });
}
