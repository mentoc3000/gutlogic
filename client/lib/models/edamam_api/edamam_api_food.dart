import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import './edamam_api_nutrients.dart';

part 'edamam_api_food.g.dart';

abstract class EdamamApiFood implements Built<EdamamApiFood, EdamamApiFoodBuilder> {
  static Serializer<EdamamApiFood> get serializer => _$edamamApiFoodSerializer;

  @nullable
  String get foodId;

  @nullable
  String get label;

  @nullable
  EdamamApiNutrients get nutrients;

  @nullable
  String get category;

  @nullable
  String get image;

  EdamamApiFood._();

  factory EdamamApiFood([void Function(EdamamApiFoodBuilder) updates]) = _$EdamamApiFood;
}
