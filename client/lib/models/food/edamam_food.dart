import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/edamam_food_reference.dart';
import '../measure.dart';
import '../pantry/pantry_entry_reference.dart';
import 'food.dart';

part 'edamam_food.g.dart';

abstract class EdamamFood implements Food, Built<EdamamFood, EdamamFoodBuilder> {
  static Serializer<EdamamFood> get serializer => _$edamamFoodSerializer;

  EdamamFood._();

  factory EdamamFood({
    required String id,
    required String name,
    BuiltList<Measure>? measures,
    PantryEntryReference? pantryEntryReference,
    String? brand,
  }) =>
      _$EdamamFood._(
        id: id,
        name: name,
        measures: measures ?? Food.defaultMeasures,
        pantryEntryReference: pantryEntryReference,
        brand: brand,
      );

  factory EdamamFood.fromBuilder([EdamamFoodBuilder Function(EdamamFoodBuilder) updates]) = _$EdamamFood;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;

  @override
  EdamamFoodReference toFoodReference() => EdamamFoodReference(id: id, name: name);

  @override
  EdamamFood addPantryEntryReference(PantryEntryReference? pantryEntryReference) {
    return rebuild((b) => b.pantryEntryReference = pantryEntryReference?.toBuilder());
  }
}
