import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

import '../food_reference/food_reference.dart';
import '../measure.dart';
import '../model_interfaces.dart';
import '../pantry/pantry_entry_reference.dart';

part 'food.g.dart';

@BuiltValue(instantiable: false)
abstract class Food with Ided, Named implements Searchable {
  static BuiltList<Measure> defaultMeasures = <Measure>[].build();

  BuiltList<Measure> get measures;
  String? get brand;

  @BuiltValueField(serialize: false)
  PantryEntryReference? get pantryEntryReference;

  FoodReference toFoodReference();
  Food addPantryEntryReference(PantryEntryReference? pantryEntryReference);
}
