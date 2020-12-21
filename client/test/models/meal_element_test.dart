import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/meal_element.dart';
import 'package:gutlogic/models/quantity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('MealElement', () {
    test('constructs simple object', () {
      final foodReference = CustomFoodReference(id: '1', name: 'Bok Choy');
      final quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      final mealElement = MealElement(
        id: 'mealEntry1#mealElement1',
        foodReference: foodReference,
        quantity: quantity,
        notes: 'tender',
      );
      expect(mealElement.foodReference, foodReference);
      expect(mealElement.quantity, quantity);
      expect(mealElement.mealEntryId, 'mealEntry1');
    });

    test('is equatable', () {
      MealElement constructMealElement() {
        final foodReference = CustomFoodReference(id: '1', name: 'Bok Choy');
        final quantity = Quantity.fromBuilder((b) => b
          ..amount = 3.4
          ..unit = 'Slices');
        final mealElement = MealElement(
          id: 'mealEntry1#mealElement1',
          foodReference: foodReference,
          quantity: quantity,
          notes: 'tender',
        );

        return mealElement;
      }

      expect(constructMealElement(), constructMealElement());
    });

    test('is deserializable', () {
      final foodReference = CustomFoodReference(id: '1', name: 'Bok Choy');
      final quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      final Map<String, dynamic> foodReferenceJson = serializers.serialize(foodReference);
      final Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      final mealElementJson = {
        'id': 'mealEntry1#mealElement1',
        'foodReference': foodReferenceJson,
        'quantity': quantityJson..remove('\$'),
        'notes': 'tender',
      };
      final mealElement = serializers.deserializeWith(MealElement.serializer, mealElementJson);
      expect(mealElement.foodReference, foodReference);
      expect(mealElement.quantity, quantity);
    });

    test('is serializable', () {
      final foodReference = CustomFoodReference(id: '1', name: 'Bok Choy');
      final quantity = Quantity.fromBuilder((b) => b
        ..amount = 3.4
        ..unit = 'Slices');
      final mealElement = MealElement(
        id: 'mealEntry1#mealElement1',
        foodReference: foodReference,
        quantity: quantity,
        notes: 'tender',
      );
      final Map<String, dynamic> foodReferenceJson = serializers.serialize(foodReference);
      final Map<String, dynamic> quantityJson = serializers.serialize(quantity);
      expect(serializers.serialize(mealElement), {
        '\$': 'MealElement',
        'id': 'mealEntry1#mealElement1',
        'foodReference': foodReferenceJson,
        'quantity': quantityJson..remove('\$'),
        'notes': 'tender',
      });
      expect(serializers.serializeWith(MealElement.serializer, mealElement), {
        'id': 'mealEntry1#mealElement1',
        'foodReference': foodReferenceJson,
        'quantity': quantityJson..remove('\$'),
        'notes': 'tender',
      });
    });
  });
}
