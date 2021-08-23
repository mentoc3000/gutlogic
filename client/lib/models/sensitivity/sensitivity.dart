import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'sensitivity_level.dart';
import 'sensitivity_source.dart';

part 'sensitivity.g.dart';

abstract class Sensitivity implements Built<Sensitivity, SensitivityBuilder> {
  static Serializer<Sensitivity> get serializer => _$sensitivitySerializer;

  SensitivityLevel get level;
  SensitivitySource get source;

  static Sensitivity ofNothing = Sensitivity(level: SensitivityLevel.none, source: SensitivitySource.none);
  static Sensitivity unknown = Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.none);

  Sensitivity._();

  factory Sensitivity({
    required SensitivityLevel level,
    required SensitivitySource source,
  }) = _$Sensitivity._;

  factory Sensitivity.fromBuilder([SensitivityBuilder Function(SensitivityBuilder) updates]) = _$Sensitivity;

  factory Sensitivity.aggregate(Iterable<Sensitivity> sensitivities) {
    if (sensitivities.isEmpty) return Sensitivity.ofNothing;
    return sensitivities.reduce(combine);
  }

  static Sensitivity combine(Sensitivity a, Sensitivity b) {
    final level = SensitivityLevel.combine(a.level, b.level);
    final source = SensitivitySource.combine(a.source, b.source);
    return Sensitivity(level: level, source: source);
  }
}
