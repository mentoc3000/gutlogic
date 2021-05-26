import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import './edamam_api_nutrients.dart';

part 'edamam_api_food.g.dart';

abstract class EdamamApiFood implements Built<EdamamApiFood, EdamamApiFoodBuilder> {
  static Serializer<EdamamApiFood> get serializer => _$edamamApiFoodSerializer;

  String? get foodId;
  String? get label;
  EdamamApiNutrients? get nutrients;
  String? get brand;
  String? get category;
  String? get categoryLabel;
  String? get foodContentsLabel;
  String? get image;

  EdamamApiFood._();

  factory EdamamApiFood([void Function(EdamamApiFoodBuilder) updates]) = _$EdamamApiFood;
}
