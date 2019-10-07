import 'package:test/test.dart';
import 'package:gut_ai/models/quantity.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Quantity', () {
    test('constructs simple object', () {
      Quantity quantity = Quantity(amount: 3, unit: 'Cups');
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });

    test('is equatable', () {
      final constructQuantity = () => Quantity.fromBuilder((b) => b
        ..amount = 3
        ..unit = 'Cups');
      expect(constructQuantity(), constructQuantity());
    });

    test('is deserializable', () {
      Map<String, dynamic> quantityJson = {
        "amount": 3.0,
        "unit": "Cups",
      };
      Quantity quantity =
          serializers.deserializeWith(Quantity.serializer, quantityJson);
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });

    test('is serializable', () {
      Quantity quantity = Quantity.fromBuilder((b) => b
        ..amount = 3
        ..unit = 'Cups');
      expect(serializers.serialize(quantity), {
        "\$": "Quantity",
        "amount": 3.0,
        "unit": "Cups",
      });
    });
  });
}
