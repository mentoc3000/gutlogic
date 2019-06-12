import 'package:test/test.dart';
import 'package:gut_ai/models/serializers.dart';
import 'package:gut_ai/models/dose.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('Dose', () {
    test('constructs simple object', () {
      Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Tomato');
      Quantity quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Dose dose = Dose(medicine: medicine, quantity: quantity);
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });

    test('is equatable', () {
      final constructIngredient = () {
        Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Tomato');
        Quantity quantity = Quantity.fromBuilder((b) => b
          ..amount = 3.4
          ..unit = 'Slices');
        Dose dose = Dose.fromBuilder((b) => b
          ..medicine = medicine.toBuilder()
          ..quantity = quantity.toBuilder());
        return dose;
      };
      expect(constructIngredient(), constructIngredient());
    });

    test('is deserializable', () {
      Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Tomato');
      Quantity quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Map<String, dynamic> medicineJson = serializers.serialize(medicine);
      Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      Map<String, dynamic> doseJson = {
        'medicine': medicineJson..remove('\$'),
        'quantity': quantityJson..remove('\$'),
      };
      Dose dose = serializers.deserializeWith(Dose.serializer, doseJson);
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });

    test('is serializable', () {
      Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Tomato');
      Quantity quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      Dose dose = Dose.fromBuilder((b) => b
        ..medicine = medicine.toBuilder()
        ..quantity = quantity.toBuilder());
      Map<String, dynamic> medicineJson = serializers.serialize(medicine);
      Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      expect(serializers.serialize(dose), {
        '\$': 'Dose',
        'medicine': medicineJson..remove('\$'),
        'quantity': quantityJson..remove('\$'),
      });
    });
  });
}
