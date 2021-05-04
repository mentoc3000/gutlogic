import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/measure.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('Quantity', () {
    test('constructs simple object', () {
      final quantity = Quantity(amount: 3, measure: Measure(unit: 'Cup', weight: 240));
      expect(quantity.amount, 3.0);
      expect(quantity.measure!.unit, 'Cup');
      expect(quantity.measure!.weight, 240);
    });

    test('constructs object from amount and unit', () {
      final quantity = Quantity.unweighed(amount: 3, unit: 'Tablespoons');
      expect(quantity.amount, 3.0);
      expect(quantity.measure!.unit, 'Tablespoons');
      expect(quantity.measure!.weight, null);
    });

    test('constructs empty', () {
      final quantity = Quantity();
      expect(quantity.amount, null);
      expect(quantity.measure, null);
    });

    test('is equatable', () {
      Quantity constructQuantity() => Quantity.fromBuilder((b) => b
        ..amount = 3
        ..measure.unit = 'Cups');
      expect(constructQuantity(), constructQuantity());
    });

    test('is deserializable', () {
      final measure = Measure(unit: 'Cup', weight: 240);
      final quantityJson = {
        'amount': 3.0,
        'measure': serializers.serializeWith(Measure.serializer, measure),
      };
      final quantity = serializers.deserializeWith(Quantity.serializer, quantityJson);
      expect(quantity!.amount, 3.0);
      expect(quantity.measure!.unit, 'Cup');
    });

    test('is serializable', () {
      final quantity = Quantity.fromBuilder((b) => b
        ..amount = 3
        ..measure.unit = 'Cups');
      expect(serializers.serialize(quantity), {
        '\$': 'Quantity',
        'amount': 3.0,
        'measure': {'unit': 'Cups'},
      });
    });

    test('converts to human-readable string', () {
      final quantity = Quantity.unweighed(amount: 3, unit: 'tsp');
      expect(quantity.toString(), '3.0 tsp');
    });

    test('converts to another measure', () {
      final measure1 = Measure(unit: 'Cup', weight: 240);
      final measure2 = Measure(unit: 'Tablespoon', weight: 15);
      final quantity1 = Quantity(amount: 1, measure: measure1);
      final quantity2 = quantity1.convertTo(measure2);
      expect(quantity2.amount, 16);
      expect(quantity2.measure!.unit, measure2.unit);
    });

    test('converts to unweighed measure', () {
      final measure1 = Measure(unit: 'Cup', weight: 240);
      final measure2 = Measure(unit: 'Tablespoon');
      final quantity1 = Quantity(amount: 1, measure: measure1);
      final quantity2 = quantity1.convertTo(measure2);
      expect(quantity2.amount, quantity1.amount);
      expect(quantity2.measure!.unit, measure2.unit);
      expect(quantity2.measure!.weight, null);
    });
  });
}
