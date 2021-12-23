import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/user_food_details_api.dart';
import 'package:test/test.dart';

void main() {
  group('UserFoodDetailsApi', () {
    test('is serializable', () {
      const id = 'id';
      final foodReference = CustomFoodReference(id: 'foodId', name: 'Cabbage');
      const sensitivityLevel = SensitivityLevel.moderate;
      final userFoodDetailsApi = UserFoodDetailsApi.fromBuilder((b) => b
        ..id = id
        ..foodReference = foodReference
        ..sensitivityLevel = sensitivityLevel
        ..notes = 'Tasty!');
      final serializedFoodReference = serializers.serialize(foodReference) as Map<String, dynamic>;
      final serializedSensitivity = serializers.serializeWith(SensitivityLevel.serializer, sensitivityLevel) as int;
      expect(serializers.serialize(userFoodDetailsApi), {
        '\$': 'UserFoodDetailsApi',
        'foodReference': serializedFoodReference,
        'sensitivity': serializedSensitivity,
        'id': id,
        'notes': userFoodDetailsApi.notes,
      });
    });

    test('is deserializable', () {
      final userFoodDetailsApiJson = {
        'id': 'pantryId',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
        'notes': 'Tasty!'
      };
      final userFoodDetailsApi = serializers.deserializeWith(UserFoodDetailsApi.serializer, userFoodDetailsApiJson)!;
      expect(userFoodDetailsApi.foodReference.name, 'Crepe');
      expect(userFoodDetailsApi.notes, userFoodDetailsApiJson['notes']);
      expect(userFoodDetailsApi.sensitivityLevel, SensitivityLevel.moderate);
    });

    test('is deserializable with extra key/value pairs', () {
      final pantryEntryJson = {
        'id': 'pantryId',
        'type': 'PANTRY_ENTRY',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
        'notes': 'Tasty!'
      };
      final userFoodDetailsApi = serializers.deserializeWith(UserFoodDetailsApi.serializer, pantryEntryJson)!;
      expect(userFoodDetailsApi.foodReference.name, 'Crepe');
      expect(userFoodDetailsApi.notes, pantryEntryJson['notes']);
      expect(userFoodDetailsApi.sensitivityLevel, SensitivityLevel.moderate);
    });
  });
}
