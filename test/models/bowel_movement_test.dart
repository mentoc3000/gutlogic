import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/bowel_movement.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('BowelMovement', () {
    test('constructs empty object', () {
      BowelMovement bm = BowelMovement();
      expect(bm.type, null);
      expect(bm.volume, null);
    });

    test('constructs simple object', () {
      BowelMovement bm = BowelMovement((b) => b
        ..type = 3
        ..volume = 4);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is equatable', () {
      final constructBM = () => BowelMovement((b) => b
        ..type = 3
        ..volume = 4);
      expect(constructBM(), constructBM());
    });

    test('is deserializable', () {
      const String bmJson = "{ 'type': 3, 'volume': 4 }";
      BowelMovement bm = serializers.deserializeWith(BowelMovement.serializer, json.encode(bmJson));
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is serializable', () {
      BowelMovement bm = BowelMovement((b) => b
        ..type = 3
        ..volume = 4);
      expect(json.encode(serializers.serialize(bm)), "{ 'type': 3, 'volume': 4 }");
    });
  });
}
