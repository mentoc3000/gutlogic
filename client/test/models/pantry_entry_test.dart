import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('PantryEntry', () {
    test('is serializable', () {
      const id = 'id';
      final foodReference = CustomFoodReference(id: 'foodId', name: 'Cabbage');
      const sensitivity = Sensitivity.moderate;
      final pantryEntry = PantryEntry.fromBuilder((b) => b
        ..id = id
        ..foodReference = foodReference
        ..sensitivity = sensitivity
        ..notes = 'Tasty!');
      final serializedFoodReference = serializers.serialize(foodReference) as Map<String, dynamic>;
      final serializedSensitivity = serializers.serializeWith(Sensitivity.serializer, sensitivity) as int;
      expect(serializers.serialize(pantryEntry), {
        '\$': 'PantryEntry',
        'foodReference': serializedFoodReference,
        'sensitivity': serializedSensitivity,
        'id': id,
        'notes': pantryEntry.notes,
      });
    });

    test('is deserializable', () {
      final pantryEntryJson = {
        'id': 'pantryId',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
        'notes': 'Tasty!'
      };
      final pantryEntry = serializers.deserializeWith(PantryEntry.serializer, pantryEntryJson)!;
      expect(pantryEntry.foodReference.name, 'Crepe');
      expect(pantryEntry.notes, pantryEntryJson['notes']);
      expect(pantryEntry.sensitivity, Sensitivity.moderate);
    });

    test('is deserializable with extra key/value pairs', () {
      final pantryEntryJson = {
        'id': 'pantryId',
        'type': 'PANTRY_ENTRY',
        'foodReference': {'\$': 'CustomFoodReference', 'id': 'foodId', 'name': 'Crepe'},
        'sensitivity': 2,
        'notes': 'Tasty!'
      };
      final pantryEntry = serializers.deserializeWith(PantryEntry.serializer, pantryEntryJson)!;
      expect(pantryEntry.foodReference.name, 'Crepe');
      expect(pantryEntry.notes, pantryEntryJson['notes']);
      expect(pantryEntry.sensitivity, Sensitivity.moderate);
    });

    test('converts to a reference', () {
      final pantryEntry = PantryEntry(
        id: 'id',
        foodReference: CustomFoodReference(id: 'foodid', name: 'Great Northern Beams'),
        sensitivity: Sensitivity.mild,
      );
      final pantryEntryReference = pantryEntry.toReference();
      expect(pantryEntryReference.sensitivity, pantryEntry.sensitivity);
    });
  });
}
