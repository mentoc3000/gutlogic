import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../irritant.dart';
import 'food_reference.dart';

part 'edamam_food_reference.g.dart';

abstract class EdamamFoodReference implements FoodReference, Built<EdamamFoodReference, EdamamFoodReferenceBuilder> {
  static Serializer<EdamamFoodReference> get serializer => _$edamamFoodReferenceSerializer;

  EdamamFoodReference._();

  factory EdamamFoodReference({
    required String id,
    required String name,
    BuiltList<Irritant>? irritants,
  }) = _$EdamamFoodReference._;

  factory EdamamFoodReference.fromBuilder([EdamamFoodReferenceBuilder Function(EdamamFoodReferenceBuilder) updates]) =
      _$EdamamFoodReference;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;
}
