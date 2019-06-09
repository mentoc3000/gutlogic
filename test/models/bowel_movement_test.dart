import 'package:test/test.dart';
import 'package:gut_ai/models/bowel_movement.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('BowelMovement', () {
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
      Map<String, dynamic> bmJson = {"type": 3, "volume": 4};
      BowelMovement bm =
          serializers.deserializeWith(BowelMovement.serializer, bmJson);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is serializable', () {
      BowelMovement bm = BowelMovement((b) => b
        ..type = 3
        ..volume = 4);
      expect(serializers.serialize(bm), {
        "\$": "BowelMovement",
        "type": 3,
        "volume": 4,
      });
    });
  });
}
