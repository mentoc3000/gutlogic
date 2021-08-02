import 'package:gutlogic/input/input.dart';
import 'package:test/test.dart';

class TestInputGroup extends InputGroup {
  final Input<bool> a = Input<bool>(true, (value) => value ? null : 'Field must be true.');
  final Input<bool> b = Input<bool>(true, (value) => value ? null : 'Field must be true.');

  @override
  List<Input> get inputs => [a, b];
}

void main() {
  group('InputGroup', () {
    test('input group state aggregates input state', () async {
      final group = TestInputGroup();

      expect(group.dirty, equals(false));
      expect(group.valid, equals(true));

      group.a.set(false);
      group.update();

      expect(group.a.dirty, equals(true));
      expect(group.a.valid, equals(false));

      expect(group.b.dirty, equals(false));
      expect(group.b.valid, equals(true));

      expect(group.dirty, equals(true));
      expect(group.valid, equals(false));

      group.a.set(true);
      group.update();

      expect(group.a.dirty, equals(true));
      expect(group.a.valid, equals(true));

      expect(group.b.dirty, equals(false));
      expect(group.b.valid, equals(true));

      expect(group.dirty, equals(true));
      expect(group.valid, equals(true));
    });
  });
}
