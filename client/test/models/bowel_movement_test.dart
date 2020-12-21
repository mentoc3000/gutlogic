import 'package:gutlogic/models/bowel_movement.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('BowelMovement', () {
    test('constructs simple object', () {
      final bm = BowelMovement(type: 3, volume: 4);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is equatable', () {
      BowelMovement constructBM() => BowelMovement.fromBuilder((b) => b
        ..type = 3
        ..volume = 4);
      expect(constructBM(), constructBM());
    });

    test('is deserializable', () {
      final bmJson = {'type': 3, 'volume': 4};
      final bm = serializers.deserializeWith(BowelMovement.serializer, bmJson);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is serializable', () {
      final bm = BowelMovement.fromBuilder((b) => b
        ..type = 3
        ..volume = 4);
      expect(serializers.serialize(bm), {
        '\$': 'BowelMovement',
        'type': 3,
        'volume': 4,
      });
      expect(serializers.serializeWith(BowelMovement.serializer, bm), {
        'type': 3,
        'volume': 4,
      });
    });
  });
}
