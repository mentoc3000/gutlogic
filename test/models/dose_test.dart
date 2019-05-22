import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/dose.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/quantity.dart';

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
      expect(dose.medicine, 3);
      expect(dose.quantity, 4);
    });

    test('is equatable', () {
      final constructDose = () => Dose(
            medicine: Medicine(),
            quantity: Quantity(),
          );
      expect(constructDose(), constructDose());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> doseJson = {
        'medicine': 3,
        'quantity': 4,
      };
      Dose dose = Dose.fromJson(doseJson);
      expect(dose.medicine, 3);
      expect(dose.quantity, 4);
    });
  });
}
