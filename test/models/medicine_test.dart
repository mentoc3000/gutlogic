import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Medicine', () {
    test('constructs simple object', () {
      Medicine medicine = Medicine((b) => b..name = 'Pro-8');
      expect(medicine.name, 'Pro-8');
    });

    test('is equatable', () {
      final constructMedicine = () => Medicine((b) => b..name = 'Pro-8');
      expect(constructMedicine(), constructMedicine());
    });

    test('is deserializable', () {
      const String medicineJson = '{"name":"Pro-8"}';
      Medicine medicine = serializers.deserializeWith(Medicine.serializer, json.decode(medicineJson));
      expect(medicine.name, 'Pro-8');
    });

    test('is serializable', () {
      Medicine medicine = Medicine((b) => b..name = 'Pro-8');
      expect(json.encode(serializers.serialize(medicine)), '{"\$":"Medicine","name":"Pro-8"}');
    });

    test('has a search heading', () {
      Medicine medicine = Medicine((b) => b..name = 'Pro-8');
      expect(medicine.searchHeading(), medicine.name);
    });
  });
}
