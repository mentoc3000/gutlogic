import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'food_reference/food_reference.dart';

part 'food_group.g.dart';

abstract class FoodGroup implements Built<FoodGroup, FoodGroupBuilder> {
  static Serializer<FoodGroup> get serializer => _$foodGroupSerializer;

  String get name;
  BuiltSet<FoodReference> get foodRefs;

  FoodGroup._();

  factory FoodGroup({required String name, required BuiltSet<FoodReference> foodRefs}) = _$FoodGroup._;

  factory FoodGroup.fromBuilder([FoodGroupBuilder Function(FoodGroupBuilder) updates]) = _$FoodGroup;
}
