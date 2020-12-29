import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'measure.g.dart';

abstract class Measure implements Built<Measure, MeasureBuilder> {
  static Serializer<Measure> get serializer => _$measureSerializer;

  String get unit;

  // EdamamFoods will have measure with weights to allow for unit conversion, but CustomFoods will only have the unit.
  @nullable
  double get weight; // in grams

  Measure._();

  factory Measure({@required String unit, double weight}) = _$Measure._;

  factory Measure.fromBuilder([MeasureBuilder Function(MeasureBuilder) updates]) = _$Measure;

  factory Measure.empty() => Measure(unit: '');

  @override
  String toString() => '$unit ($weight g)';
}
