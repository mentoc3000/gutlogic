import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('Quantity', () {
    test('constructs empty object', () {
      Quantity quantity = Quantity();
      expect(quantity.amount, null);
      expect(quantity.unit, null);
    });

    test('constructs simple object', () {
      Quantity quantity = Quantity(amount: 3.0, unit: 'Cups');
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });

    test('is equatable', () {
      final constructQuantity = () => Quantity(amount: 3, unit: 'Cups');
      expect(constructQuantity(), constructQuantity());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> quantityJson = {
        'amount': 3.0,
        'unit': 'Cups',
      };
      Quantity quantity = Quantity.fromJson(quantityJson);
      expect(quantity.amount, 3.0);
      expect(quantity.unit, 'Cups');
    });
  });
}
