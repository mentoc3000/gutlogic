import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

part 'sensitivity_source.g.dart';

class SensitivitySource extends EnumClass {
  static Serializer<SensitivitySource> get serializer => _$sensitivitySourceSerializer;

  static const SensitivitySource user = _$user;
  static const SensitivitySource aggregation = _$aggregation;
  static const SensitivitySource none = _$none;

  const SensitivitySource._(String name) : super(name);

  static BuiltSet<SensitivitySource> get values => _$values;
  static SensitivitySource valueOf(String name) => _$valueOf(name);

  static SensitivitySource combine(SensitivitySource a, SensitivitySource b) {
    if (a == b) return a;
    if (a == SensitivitySource.none) return b;
    if (b == SensitivitySource.none) return a;
    return SensitivitySource.aggregation;
  }
}
