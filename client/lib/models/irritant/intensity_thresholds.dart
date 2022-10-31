import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'intensity_thresholds.g.dart';

abstract class IntensityThresholds implements Built<IntensityThresholds, IntensityThresholdsBuilder> {
  static Serializer<IntensityThresholds> get serializer => _$intensityThresholdsSerializer;

  /// Irritant name
  String get name;

  /// Dose divisions between intensity levels
  /// Last step indicates highest intensity level
  BuiltList<double> get intensitySteps;

  IntensityThresholds._();

  factory IntensityThresholds.fromBuilder([IntensityThresholdsBuilder Function(IntensityThresholdsBuilder) updates]) =
      _$IntensityThresholds;
}
