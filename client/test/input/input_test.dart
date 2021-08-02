import 'package:gutlogic/input/input.dart';
import 'package:test/test.dart';

void main() {
  group('Input', () {
    test('input state updates with value changes', () {
      final input = Input<bool>(true, (value) => value ? null : 'Field must be true.');

      expect(input.value, equals(true));
      expect(input.error, equals(null));
      expect(input.valid, equals(true));
      expect(input.dirty, equals(false));

      input.set(false);

      expect(input.value, equals(false));
      expect(input.error, equals('Field must be true.'));
      expect(input.valid, equals(false));
      expect(input.dirty, equals(true));

      input.set(true);

      expect(input.value, equals(true));
      expect(input.error, equals(null));
      expect(input.valid, equals(true));
      expect(input.dirty, equals(true));
    });
  });
}
