import 'package:built_collection/src/list.dart';
import 'package:test/test.dart';
import 'package:gut_ai/resources/medicine_repository.dart';
import 'package:gut_ai/models/medicine.dart';
import 'package:gut_ai/models/serializers.dart';

void main() {
  group('Medicine Repository', () {
    test('fetches all medicines', () async {
      final items = [
        {"name": "Fiber"},
        {"name": "Probiotic"}
      ];
      MedicineRepository medicineRepository = MedicineRepository();
      BuiltList<Medicine> medicines = await medicineRepository.fetchAll();
      expect(
        medicines,
        items
            .map((x) => serializers.deserializeWith(Medicine.serializer, x))
            .toList(),
      );
    });
  });
}
