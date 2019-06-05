import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'model_interfaces.dart';
import 'irritant.dart';

part 'food.g.dart';

abstract class Food implements Built<Food, FoodBuilder>, Searchable {
  static Serializer<Food> get serializer => _$foodSerializer;

  String get name;
  BuiltList<Irritant> get irritants;

  Food._();
  factory Food([updates(FoodBuilder b)]) = _$Food;

  String searchHeading() => name;
}
