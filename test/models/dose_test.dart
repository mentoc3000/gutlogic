import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/dose.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/quantity.dart';

void main() {
  group('Dose', () {

    test('constructs simple object', () {
      Medicine medicine = Medicine((b) => b..name = 'Tomato');
      Quantity quantity = Quantity();
      Dose dose = Dose(
        medicine: medicine,
        quantity: quantity,
      );
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });

    test('is equatable', () {
      final constructIngredient = () => Dose(
            medicine: Medicine(),
            quantity: Quantity(),
          );
      expect(constructIngredient(), constructIngredient());
    });

    test('is deserializable', () {
      Medicine medicine = Medicine(name: 'Pro-8');
      Quantity quantity = Quantity(amount: 3, unit: 'Pills');
      Map<String, dynamic> ingredientJson = {
        'medicine': medicine.toJson(),
        'quantity': quantity.toJson(),
      };
      Dose dose = Dose.fromJson(ingredientJson);
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });

    test('is serializable', () {
      Quantity quantity = Quantity(amount: 1.2);
      Medicine medicine = Medicine(
        name: 'Garlic',
      );
      Dose dose = Dose(
            medicine: medicine,
            quantity: quantity,
          );
      expect(dose.toJson(), {
        'medicine': medicine.toJson(),
        'quantity': quantity.toJson(),
      });
    });
  });
}
