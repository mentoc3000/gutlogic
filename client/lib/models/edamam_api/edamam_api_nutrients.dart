// ignore_for_file: non_constant_identifier_names

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edamam_api_nutrients.g.dart';

abstract class EdamamApiNutrients implements Built<EdamamApiNutrients, EdamamApiNutrientsBuilder> {
  static Serializer<EdamamApiNutrients> get serializer => _$edamamApiNutrientsSerializer;

  @nullable
  double get ENERC_KCAL;

  @nullable
  double get PROCNT;

  @nullable
  double get FAT;

  @nullable
  double get CHOCDF;

  @nullable
  double get FIBTG;

  EdamamApiNutrients._();

  factory EdamamApiNutrients([void Function(EdamamApiNutrientsBuilder) updates]) = _$EdamamApiNutrients;
}
