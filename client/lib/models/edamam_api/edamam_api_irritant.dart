import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../irritant.dart';

part 'edamam_api_irritant.g.dart';

abstract class EdamamApiIrritant implements Built<EdamamApiIrritant, EdamamApiIrritantBuilder> {
  static Serializer<EdamamApiIrritant> get serializer => _$edamamApiIrritantSerializer;

  String get name;
  bool get isPresent;
  double? get concentration;

  EdamamApiIrritant._();

  factory EdamamApiIrritant([void Function(EdamamApiIrritantBuilder) updates]) = _$EdamamApiIrritant;

  Irritant? toIrritant() => isPresent ? Irritant(name: name, concentration: concentration) : null;
}
