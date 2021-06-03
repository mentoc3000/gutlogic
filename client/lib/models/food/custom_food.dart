import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/custom_food_reference.dart';
import '../irritant.dart';
import '../measure.dart';
import '../model_interfaces.dart';
import '../pantry/pantry_entry_reference.dart';
import 'food.dart';

part 'custom_food.g.dart';

abstract class CustomFood implements Food, Built<CustomFood, CustomFoodBuilder>, Searchable {
  static Serializer<CustomFood> get serializer => _$customFoodSerializer;

  CustomFood._();

  factory CustomFood({
    required String id,
    required String name,
    PantryEntryReference? pantryEntryReference,
    BuiltList<Irritant>? irritants,
  }) =>
      _$CustomFood._(
        id: id,
        name: name,
        measures: Food.defaultMeasures,
        pantryEntryReference: pantryEntryReference,
        irritants: irritants,
        brand: null,
      );

  factory CustomFood.fromBuilder([CustomFoodBuilder Function(CustomFoodBuilder) updates]) = _$CustomFood;

  @override
  CustomFoodReference toFoodReference() => CustomFoodReference(id: id, name: name, irritants: irritants);

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;

  @override
  CustomFood addPantryEntryReference(PantryEntryReference? pantryEntryReference) {
    return rebuild((b) => b.pantryEntryReference = pantryEntryReference?.toBuilder());
  }
}
