import 'package:test/test.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Medicine', () {
    test('constructs simple object', () {
      Medicine medicine = Medicine(name: 'Pro-8');
      expect(medicine.name, 'Pro-8');
    });

    test('is equatable', () {
      final constructMedicine =
          () => Medicine.fromBuilder((b) => b..name = 'Pro-8');
      expect(constructMedicine(), constructMedicine());
    });

    test('is deserializable', () {
      Map<String, dynamic> medicineJson = {"name": "Pro-8"};
      Medicine medicine =
          serializers.deserializeWith(Medicine.serializer, medicineJson);
      expect(medicine.name, 'Pro-8');
    });

    test('is serializable', () {
      Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Pro-8');
      expect(
          serializers.serialize(medicine), {"\$": "Medicine", "name": "Pro-8"});
      expect(serializers.serializeWith(Medicine.serializer, medicine),
          {"name": "Pro-8"});
    });

    test('has a search heading', () {
      Medicine medicine = Medicine.fromBuilder((b) => b..name = 'Pro-8');
      expect(medicine.searchHeading(), medicine.name);
    });
  });
}
