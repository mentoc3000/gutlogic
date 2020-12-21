import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Quantity', () {
    test('constructs simple object', () {
      final quantity = Quantity(amount: 3, unit: 'Cups');
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });

    test('is equatable', () {
      Quantity constructQuantity() => Quantity.fromBuilder((b) => b
        ..amount = 3
        ..unit = 'Cups');
      expect(constructQuantity(), constructQuantity());
    });

    test('is deserializable', () {
      final quantityJson = {
        'amount': 3.0,
        'unit': 'Cups',
      };
      final quantity = serializers.deserializeWith(Quantity.serializer, quantityJson);
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });

    test('is serializable', () {
      final quantity = Quantity.fromBuilder((b) => b
        ..amount = 3
        ..unit = 'Cups');
      expect(serializers.serialize(quantity), {
        '\$': 'Quantity',
        'amount': 3.0,
        'unit': 'Cups',
      });
    });

    test('converts to human-readable string', () {
      final quantity = Quantity(amount: 3, unit: 'tsp');
      expect(quantity.toString(), '3.0 tsp');
    });
  });
}
