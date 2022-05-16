import 'package:gutlogic/util/math.dart';
import 'package:test/test.dart';

void main() {
  group('Math Utilities', () {
    test('lerp', () {
      expect(lerp(0.0, 0.0, 1.0), 0.0);
      expect(lerp(0.5, 0.0, 1.0), 0.5);
      expect(lerp(1.0, 0.0, 1.0), 1.0);

      expect(lerp(0.0, 0.0, 2.0), 0.0);
      expect(lerp(0.5, 0.0, 2.0), 1.0);
      expect(lerp(1.0, 0.0, 2.0), 2.0);
    });

    test('unlerp', () {
      expect(unlerp(0.0, 0.0, 1.0), 0.0);
      expect(unlerp(0.5, 0.0, 1.0), 0.5);
      expect(unlerp(1.0, 0.0, 1.0), 1.0);

      expect(unlerp(0.0, 0.0, 2.0), 0.0);
      expect(unlerp(1.0, 0.0, 2.0), 0.5);
      expect(unlerp(2.0, 0.0, 2.0), 1.0);
    });

    test('remap', () {
      expect(remap(0.0, 0.0, 1.0, 0.0, 2.0), 0.0);
      expect(remap(0.5, 0.0, 1.0, 0.0, 2.0), 1.0);
      expect(remap(1.0, 0.0, 1.0, 0.0, 2.0), 2.0);

      expect(remap(0.0, 0.0, 2.0, 0.0, 1.0), 0.0);
      expect(remap(1.0, 0.0, 2.0, 0.0, 1.0), 0.5);
      expect(remap(2.0, 0.0, 2.0, 0.0, 1.0), 1.0);
    });

    test('clamp', () {
      expect(clamp(0.0, 0.0, 1.0), 0.0);
      expect(clamp(0.5, 0.0, 1.0), 0.5);
      expect(clamp(1.0, 0.0, 1.0), 1.0);

      expect(clamp(0.0, 1.0, 2.0), 1.0);
      expect(clamp(3.0, 1.0, 2.0), 2.0);
    });

    test('saturate', () {
      expect(saturate(0.0), 0.0);
      expect(saturate(0.5), 0.5);
      expect(saturate(1.0), 1.0);

      expect(saturate(0.0), 0.0);
      expect(saturate(3.0), 1.0);
    });
  });
}
