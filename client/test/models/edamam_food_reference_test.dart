import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';
import 'package:gutlogic/models/food_reference/edamam_food_reference.dart';
import 'package:gutlogic/models/irritant.dart';

void main() {
  group('EdamamFoodReference', () {
    test('constructs simple object', () {
      final irritants = [Irritant(name: 'Fructan', concentration: .0032), Irritant(name: 'Sorbitol')].build();
      final edamamFoodReference = EdamamFoodReference(id: '1', name: 'Brine', irritants: irritants);
      expect(edamamFoodReference.name, 'Brine');
      expect(edamamFoodReference.irritants, irritants);
    });
  });
}
