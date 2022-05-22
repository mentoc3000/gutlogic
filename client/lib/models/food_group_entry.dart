import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'food_reference/food_reference.dart';

part 'food_group_entry.g.dart';

abstract class FoodGroupEntry implements Built<FoodGroupEntry, FoodGroupEntryBuilder> {
  static Serializer<FoodGroupEntry> get serializer => _$foodGroupEntrySerializer;

  String get group;
  FoodReference get foodRef;

  /// Irritant dose in g from one serving of the food
  BuiltMap<String, double> get doses;

  FoodGroupEntry._();

  factory FoodGroupEntry({
    required String group,
    required FoodReference foodRef,
    required BuiltMap<String, double> doses,
  }) = _$FoodGroupEntry._;

  factory FoodGroupEntry.fromBuilder([FoodGroupEntryBuilder Function(FoodGroupEntryBuilder) updates]) =
      _$FoodGroupEntry;
}
