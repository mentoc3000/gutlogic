import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'food_reference/food_reference.dart';
import 'model_interfaces.dart';
import 'pantry_entry_reference.dart';
import 'sensitivity.dart';

part 'pantry_entry.g.dart';

// TODO: move all pantry-related models into subdirectory

abstract class PantryEntry with Ided, Noted implements Built<PantryEntry, PantryEntryBuilder>, Searchable {
  static Serializer<PantryEntry> get serializer => _$pantryEntrySerializer;

  FoodReference get foodReference;
  Sensitivity get sensitivity;

  PantryEntry._();

  factory PantryEntry({
    @required String id,
    @required FoodReference foodReference,
    @required Sensitivity sensitivity,
    String notes,
  }) = _$PantryEntry._;

  factory PantryEntry.fromBuilder([PantryEntryBuilder Function(PantryEntryBuilder) updates]) = _$PantryEntry;

  @override
  String searchHeading() => foodReference.name;

  @override
  String queryText() => foodReference.name;

  PantryEntryReference toReference() => PantryEntryReference(id: id, sensitivity: sensitivity);
}
