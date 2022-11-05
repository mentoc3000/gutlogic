import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/edamam_food_reference.dart';
import '../irritant/irritant.dart';
import '../measure.dart';
import 'food.dart';

part 'edamam_food.g.dart';

abstract class EdamamFood implements Food, Built<EdamamFood, EdamamFoodBuilder> {
  static Serializer<EdamamFood> get serializer => _$edamamFoodSerializer;

  EdamamFood._();

  factory EdamamFood({
    required String id,
    required String name,
    BuiltList<Measure>? measures,
    String? brand,
    BuiltList<Irritant>? irritants,
  }) =>
      _$EdamamFood._(
        id: id,
        name: name,
        measures: measures ?? Food.defaultMeasures,
        brand: brand,
        irritants: irritants,
      );

  factory EdamamFood.fromBuilder([EdamamFoodBuilder Function(EdamamFoodBuilder) updates]) = _$EdamamFood;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;

  @override
  EdamamFoodReference toFoodReference() => EdamamFoodReference(id: id, name: name);
}
