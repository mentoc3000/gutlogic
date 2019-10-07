import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'ingredient.dart';

part 'meal.g.dart';

abstract class Meal implements Built<Meal, MealBuilder> {
  static Serializer<Meal> get serializer => _$mealSerializer;

  BuiltList<Ingredient> get ingredients;

  Meal._();
  factory Meal({@required BuiltList<Ingredient> ingredients}) = _$Meal._;
  factory Meal.fromBuilder([updates(MealBuilder b)]) = _$Meal;
  factory Meal.empty() => Meal.fromBuilder(
      (b) => b..ingredients = BuiltList<Ingredient>([]).toBuilder());
}
