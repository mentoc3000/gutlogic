import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/medicine.dart';

void main() {
  group('Medicine', () {
    test('constructs empty object', () {
      Medicine medicine = Medicine();
      expect(medicine.name, null);
    });

    test('constructs simple object', () {
      Medicine medicine = Medicine(name: 'Pro-8');
      expect(medicine.name, 'Pro-8');
    });

    test('is equatable', () {
      final constructMedicine = () => Medicine(name: 'Pro-8');
      expect(constructMedicine(), constructMedicine());
    });

    test('is constructable from JSON', () {
      const Map<String, dynamic> medicineJson = {
        'name': 'Pro-8',
      };
      Medicine medicine = Medicine.fromJson(medicineJson);
      expect(medicine.name, 'Pro-8');
    });
  });
}
