import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/edamam_food_reference.dart';
import 'irritant.dart';

part 'elementary_food.g.dart';

abstract class ElementaryFood implements Built<ElementaryFood, ElementaryFoodBuilder> {
  static Serializer<ElementaryFood> get serializer => _$elementaryFoodSerializer;

  /// Food name
  BuiltList<String> get names;

  /// Edamam food ids associated with the food
  BuiltList<String> get foodIds;

  BuiltList<Irritant> get irritants;

  /// Cannonical Edamam food
  EdamamFoodReference? get canonical;

  ElementaryFood._();

  factory ElementaryFood({
    required BuiltList<String> names,
    required BuiltList<String> foodIds,
    required BuiltList<Irritant> irritants,
    required EdamamFoodReference? canonical,
  }) =>
      _$ElementaryFood._(names: names, foodIds: foodIds, irritants: irritants, canonical: canonical);

  factory ElementaryFood.fromBuilder([ElementaryFoodBuilder Function(ElementaryFoodBuilder) updates]) =
      _$ElementaryFood;
}
