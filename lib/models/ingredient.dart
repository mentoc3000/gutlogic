import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'food.dart';
import 'quantity.dart';
import 'model_interfaces.dart';

part 'ingredient.g.dart';

abstract class Ingredient
    implements Built<Ingredient, IngredientBuilder>, Searchable {
  static Serializer<Ingredient> get serializer => _$ingredientSerializer;

  Food get food;
  Quantity get quantity;

  Ingredient._();
  factory Ingredient({@required Food food, @required Quantity quantity}) =
      _$Ingredient._;
  factory Ingredient.fromBuilder([updates(IngredientBuilder b)]) = _$Ingredient;

  String searchHeading() => food.name;
  String queryText() => food.name;
}
