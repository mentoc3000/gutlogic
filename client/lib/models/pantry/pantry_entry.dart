import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/food_reference.dart';
import '../model_interfaces.dart';
import '../sensitivity/sensitivity.dart';

part 'pantry_entry.g.dart';

abstract class PantryEntry with UserFoodDetail, Noted implements Built<PantryEntry, PantryEntryBuilder>, Searchable {
  static Serializer<PantryEntry> get serializer => _$pantryEntrySerializer;

  FoodReference get foodReference;
  Sensitivity get sensitivity;

  PantryEntry._();

  factory PantryEntry({
    required String userFoodDetailsId,
    required FoodReference foodReference,
    required Sensitivity sensitivity,
    required String? notes,
  }) = _$PantryEntry._;

  factory PantryEntry.fromBuilder([PantryEntryBuilder Function(PantryEntryBuilder) updates]) = _$PantryEntry;

  @override
  String searchHeading() => foodReference.name;

  @override
  String queryText() => foodReference.name;
}
