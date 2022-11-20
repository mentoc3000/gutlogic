import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/food_reference.dart';

part 'ingredient.g.dart';

abstract class Ingredient implements Built<Ingredient, IngredientBuilder> {
  static Serializer<Ingredient> get serializer => _$ingredientSerializer;

  String get name;
  FoodReference? get foodReference;
  BuiltList<Ingredient>? get ingredients;

  /// Maximum weight fraction of parent food or ingredient
  double get maxFracWeight;

  Ingredient._();

  factory Ingredient({
    required String name,
    required double maxFracWeight,
    FoodReference? foodReference,
    BuiltList<Ingredient>? ingredients,
  }) = _$Ingredient._;
}
