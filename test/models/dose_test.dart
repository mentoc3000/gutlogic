import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/dose.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/quantity.dart';
import 'dart:convert';

void main() {
  group('Dose', () {
    test('constructs empty object', () {
      Dose dose = Dose();
      expect(dose.medicine, null);
      expect(dose.quantity, null);
    });

    test('constructs simple object', () {
      Medicine medicine = Medicine();
      Quantity quantity = Quantity();
      Dose dose = Dose(
        medicine: medicine,
        quantity: quantity,
      );
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });

    test('is equatable', () {
      final constructDose = () => Dose(
            medicine: Medicine(),
            quantity: Quantity(),
          );
      expect(constructDose(), constructDose());
    });

    test('is constructable from JSON', () {
      Medicine medicine = Medicine(name: 'Pro-8');
      Quantity quantity = Quantity(amount: 3, unit: 'Pills');
      Map<String, dynamic> doseJson = {
        'medicine': json.encode(medicine),
        'quantity': json.encode(quantity),
      };
      Dose dose = Dose.fromJson(doseJson);
      expect(dose.medicine, medicine);
      expect(dose.quantity, quantity);
    });
  });
}
