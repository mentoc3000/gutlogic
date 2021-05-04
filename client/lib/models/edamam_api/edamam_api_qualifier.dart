// ignore_for_file: non_constant_identifier_names

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edamam_api_qualifier.g.dart';

abstract class EdamamApiQualifier implements Built<EdamamApiQualifier, EdamamApiQualifierBuilder> {
  static Serializer<EdamamApiQualifier> get serializer => _$edamamApiQualifierSerializer;

  String? get uri;

  String? get label;

  EdamamApiQualifier._();

  factory EdamamApiQualifier([void Function(EdamamApiQualifierBuilder) updates]) = _$EdamamApiQualifier;
}
