import 'package:built_value/serializer.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('SensitivityLevel', () {
    test('constructs enums', () {
      SensitivityLevel.unknown;
      SensitivityLevel.none;
      SensitivityLevel.mild;
      SensitivityLevel.moderate;
      SensitivityLevel.severe;
    });

    test('is deserializable', () {
      expect(serializers.deserializeWith(SensitivityLevel.serializer, -1), SensitivityLevel.unknown);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 0), SensitivityLevel.none);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 1), SensitivityLevel.mild);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 1.3), SensitivityLevel.mild);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 1.5), SensitivityLevel.moderate);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 2), SensitivityLevel.moderate);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 3), SensitivityLevel.severe);
      expect(serializers.deserializeWith(SensitivityLevel.serializer, 4), SensitivityLevel.severe);
    });

    test('is serializable', () {
      expect(serializers.serialize(SensitivityLevel.unknown, specifiedType: const FullType(SensitivityLevel)), -1);
      expect(serializers.serialize(SensitivityLevel.none, specifiedType: const FullType(SensitivityLevel)), 0);
      expect(serializers.serialize(SensitivityLevel.mild, specifiedType: const FullType(SensitivityLevel)), 1);
      expect(serializers.serialize(SensitivityLevel.moderate, specifiedType: const FullType(SensitivityLevel)), 2);
      expect(serializers.serialize(SensitivityLevel.severe, specifiedType: const FullType(SensitivityLevel)), 3);
    });

    test('is combinable', () {
      expect(SensitivityLevel.combine(SensitivityLevel.unknown, SensitivityLevel.unknown), SensitivityLevel.unknown);
      expect(SensitivityLevel.combine(SensitivityLevel.unknown, SensitivityLevel.severe), SensitivityLevel.severe);
      expect(SensitivityLevel.combine(SensitivityLevel.unknown, SensitivityLevel.none), SensitivityLevel.unknown);
      expect(SensitivityLevel.combine(SensitivityLevel.none, SensitivityLevel.none), SensitivityLevel.none);
      expect(SensitivityLevel.combine(SensitivityLevel.none, SensitivityLevel.mild), SensitivityLevel.mild);
      expect(SensitivityLevel.combine(SensitivityLevel.mild, SensitivityLevel.mild), SensitivityLevel.mild);
      expect(SensitivityLevel.combine(SensitivityLevel.mild, SensitivityLevel.moderate), SensitivityLevel.moderate);
      expect(SensitivityLevel.combine(SensitivityLevel.moderate, SensitivityLevel.moderate), SensitivityLevel.moderate);
      expect(SensitivityLevel.combine(SensitivityLevel.moderate, SensitivityLevel.severe), SensitivityLevel.severe);
      expect(SensitivityLevel.combine(SensitivityLevel.severe, SensitivityLevel.severe), SensitivityLevel.severe);

      expect(SensitivityLevel.aggregate([]), SensitivityLevel.unknown);
      expect(SensitivityLevel.aggregate([SensitivityLevel.mild]), SensitivityLevel.mild);
      expect(SensitivityLevel.aggregate([SensitivityLevel.mild, SensitivityLevel.moderate]),
          SensitivityLevel.combine(SensitivityLevel.mild, SensitivityLevel.moderate));
    });
  });
}
