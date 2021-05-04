import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import './edamam_api_qualified_measure.dart';

part 'edamam_api_measure.g.dart';

abstract class EdamamApiMeasure implements Built<EdamamApiMeasure, EdamamApiMeasureBuilder> {
  static Serializer<EdamamApiMeasure> get serializer => _$edamamApiMeasureSerializer;

  String? get uri;

  String? get label;

  double? get weight;

  BuiltList<EdamamApiQualifiedMeasure>? get qualified;

  EdamamApiMeasure._();

  factory EdamamApiMeasure([void Function(EdamamApiMeasureBuilder) updates]) = _$EdamamApiMeasure;
}
