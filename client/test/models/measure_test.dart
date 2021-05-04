import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Measure', () {
    test('constructs simple object', () {
      final measure = Measure(unit: 'Cup', weight: 240);
      expect(measure.unit, 'Cup');
      expect(measure.weight, 240);
    });

    test('constructs empty', () {
      final measure = Measure.empty();
      expect(measure.unit, '');
      expect(measure.weight, null);
    });

    test('is equatable', () {
      Measure constructQuantity() => Measure.fromBuilder((b) => b
        ..unit = 'Cup'
        ..weight = 240);
      expect(constructQuantity(), constructQuantity());
    });

    test('is deserializable', () {
      final quantityJson = {
        'unit': 'Cup',
        'weight': 240,
      };
      final measure = serializers.deserializeWith(Measure.serializer, quantityJson)!;
      expect(measure.unit, 'Cup');
      expect(measure.weight, 240);
    });

    test('is deserializable with label', () {
      final quantityJson = {
        'label': 'Cup',
        'weight': 240,
      };
      final measure = serializers.deserializeWith(Measure.serializer, quantityJson)!;
      expect(measure.unit, 'Cup');
      expect(measure.weight, 240);
    });

    test('is serializable', () {
      final measure = Measure.fromBuilder((b) => b
        ..weight = 3
        ..unit = 'Cups');
      expect(serializers.serialize(measure), {
        '\$': 'Measure',
        'weight': 3.0,
        'unit': 'Cups',
      });
    });

    test('converts to human-readable string', () {
      final measure = Measure(unit: 'tsp', weight: 3);
      expect(measure.toString(), 'tsp (3.0 g)');
    });
  });
}
