import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import './edamam_api_qualifier.dart';

part 'edamam_api_qualified_measure.g.dart';

abstract class EdamamApiQualifiedMeasure implements Built<EdamamApiQualifiedMeasure, EdamamApiQualifiedMeasureBuilder> {
  static Serializer<EdamamApiQualifiedMeasure> get serializer => _$edamamApiQualifiedMeasureSerializer;

  BuiltList<EdamamApiQualifier>? get qualifiers;

  double? get weight;

  EdamamApiQualifiedMeasure._();

  factory EdamamApiQualifiedMeasure([void Function(EdamamApiQualifiedMeasureBuilder) updates]) =
      _$EdamamApiQualifiedMeasure;
}
