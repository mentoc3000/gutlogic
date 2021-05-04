// ignore_for_file: non_constant_identifier_names

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edamam_api_nutrients.g.dart';

abstract class EdamamApiNutrients implements Built<EdamamApiNutrients, EdamamApiNutrientsBuilder> {
  static Serializer<EdamamApiNutrients> get serializer => _$edamamApiNutrientsSerializer;

  double? get ENERC_KCAL;

  double? get PROCNT;

  double? get FAT;

  double? get CHOCDF;

  double? get FIBTG;

  EdamamApiNutrients._();

  factory EdamamApiNutrients([void Function(EdamamApiNutrientsBuilder) updates]) = _$EdamamApiNutrients;
}
