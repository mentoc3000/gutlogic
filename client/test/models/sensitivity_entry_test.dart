import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('SensitivityEntry', () {
    test('is serializable', () {
      const id = 'id';
      final foodReference = CustomFoodReference(id: 'foodId', name: 'Cabbage');
      const sensitivityLevel = SensitivityLevel.moderate;
      final sensitivityEntry = SensitivityEntry.fromBuilder((b) => b
        ..userFoodDetailsId = id
        ..foodReference = foodReference
        ..sensitivityLevel = sensitivityLevel);
      final serializedFoodReference = serializers.serialize(foodReference) as Map<String, dynamic>;
      final serializedSensitivity = serializers.serializeWith(SensitivityLevel.serializer, sensitivityLevel) as int;
      expect(serializers.serialize(sensitivityEntry), {
        '\$': 'SensitivityEntry',
        'foodReference': serializedFoodReference,
        'sensitivity': serializedSensitivity,
        'userFoodDetailsId': id,
      });
    });

    test('is deserializable', () {
      final sensitivityEntryJson = {
        'userFoodDetailsId': 'sensitivityId',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
      };
      final sensitivityEntry = serializers.deserializeWith(SensitivityEntry.serializer, sensitivityEntryJson)!;
      expect(sensitivityEntry.foodReference.name, 'Crepe');
      expect(sensitivityEntry.sensitivityLevel, SensitivityLevel.moderate);
    });

    test('is deserializable with extra key/value pairs', () {
      final sensitivityEntryJson = {
        'userFoodDetailsId': 'sensitivityId',
        'type': 'SENSITIVITY_ENTRY',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
      };
      final sensitivityEntry = serializers.deserializeWith(SensitivityEntry.serializer, sensitivityEntryJson)!;
      expect(sensitivityEntry.foodReference.name, 'Crepe');
      expect(sensitivityEntry.sensitivityLevel, SensitivityLevel.moderate);
    });
  });
}
