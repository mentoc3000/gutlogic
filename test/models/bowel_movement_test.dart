import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/bowel_movement.dart';

void main() {
  group('BowelMovement', () {
    test('constructs empty object', () {
      BowelMovement bm = BowelMovement();
      expect(bm.type, null);
      expect(bm.volume, null);
    });

    test('constructs simple object', () {
      BowelMovement bm = BowelMovement(type: 3, volume: 4);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is equatable', () {
      final constructBM = () => BowelMovement(type: 3, volume: 4);
      expect(constructBM(), constructBM());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> bmJson = {
        'type': 3,
        'volume': 4,
      };
      BowelMovement bm = BowelMovement.fromJson(bmJson);
      expect(bm.type, 3);
      expect(bm.volume, 4);
    });

    test('is serializable', () {
      BowelMovement bm = BowelMovement(type: 3, volume: 4);
      expect(bm.toJson(), {
        'type': 3,
        'volume': 4,
      });
    });
  });
}
