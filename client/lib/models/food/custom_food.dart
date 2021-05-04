import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/custom_food_reference.dart';
import '../measure.dart';
import '../model_interfaces.dart';
import 'food.dart';

part 'custom_food.g.dart';

abstract class CustomFood implements Food, Built<CustomFood, CustomFoodBuilder>, Searchable {
  static Serializer<CustomFood> get serializer => _$customFoodSerializer;

  static BuiltList<Measure> defaultMeasures = <Measure>[].build();

  CustomFood._();

  factory CustomFood({
    required String id,
    required String name,
  }) =>
      _$CustomFood._(id: id, name: name, measures: CustomFood.defaultMeasures);

  factory CustomFood.fromBuilder([CustomFoodBuilder Function(CustomFoodBuilder) updates]) = _$CustomFood;

  @override
  CustomFoodReference toFoodReference() => CustomFoodReference(id: id, name: name);

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;
}
