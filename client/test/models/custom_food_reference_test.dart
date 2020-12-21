import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:test/test.dart';

void main() {
  group('CustomFoodReference', () {
    test('constructs simple object', () {
      final customFoodReference = CustomFoodReference(id: '1', name: 'Brine');
      expect(customFoodReference.name, 'Brine');
    });
  });
}
