import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:built_value/serializer.dart';

import 'food_reference/food_reference.dart';
import 'model_interfaces.dart';
import 'pantry_entry_reference.dart';
import 'quantity.dart';
import 'sensitivity.dart';

part 'meal_element.g.dart';

abstract class MealElement with Ided, Noted implements Built<MealElement, MealElementBuilder>, Searchable {
  static Serializer<MealElement> get serializer => _$mealElementSerializer;

  FoodReference get foodReference;

  @nullable
  Quantity get quantity;

  @nullable
  PantryEntryReference get pantryEntryReference;

  String get mealEntryId => id.split('#').first;

  MealElement._();

  factory MealElement({
    @required String id,
    @required FoodReference foodReference,
    Quantity quantity,
    PantryEntryReference pantryEntryReference,
    String notes,
  }) = _$MealElement._;

  factory MealElement.fromBuilder([MealElementBuilder Function(MealElementBuilder) updates]) = _$MealElement;

  @override
  String searchHeading() => foodReference.name;

  @override
  String queryText() => foodReference.name;

  Sensitivity getSensitivity() => pantryEntryReference?.sensitivity ?? Sensitivity.unknown;
}
