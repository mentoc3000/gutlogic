import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sensitivity_level.g.dart';

class SensitivityLevel extends EnumClass implements Comparable<SensitivityLevel> {
  @BuiltValueSerializer(custom: true)
  static Serializer<SensitivityLevel> get serializer => _severitySerializer;

  static const SensitivityLevel unknown = _$unknown;
  static const SensitivityLevel none = _$none;
  static const SensitivityLevel mild = _$mild;
  static const SensitivityLevel moderate = _$moderate;
  static const SensitivityLevel severe = _$severe;

  const SensitivityLevel._(String name) : super(name);

  static SensitivityLevel aggregate(Iterable<SensitivityLevel> levels) {
    if (levels.isEmpty) return SensitivityLevel.unknown;
    return levels.reduce(combine);
  }

  static BuiltSet<SensitivityLevel> get values => _$values;
  static SensitivityLevel valueOf(String name) => _$valueOf(name);
  static SensitivityLevel fromInt(int i) => SensitivityLevel.fromNum(i);
  static SensitivityLevel fromNum(num i) {
    if (i < 0) {
      return SensitivityLevel.unknown;
    } else if (i < 0.5) {
      return SensitivityLevel.none;
    } else if (i < 1.5) {
      return SensitivityLevel.mild;
    } else if (i < 2.5) {
      return SensitivityLevel.moderate;
    } else {
      return SensitivityLevel.severe;
    }
  }

  /// SensitivityLevel and
  ///
  /// Adding two sensitivity levels results in the higher sensitivity.
  /// Adding an unknown sensitivity level to a mild, moderate, or severe sensitivity level results in that known sensitivity.
  /// Adding an unknown sensitivity level to a none sensitivity level results in an unknown.
  static SensitivityLevel combine(SensitivityLevel a, SensitivityLevel b) {
    switch (a) {
      case SensitivityLevel.unknown:
        if (b == SensitivityLevel.none) {
          return SensitivityLevel.unknown;
        }
        return b;
      case SensitivityLevel.none:
        if (b == SensitivityLevel.unknown) {
          return SensitivityLevel.unknown;
        }
        return b;
      case SensitivityLevel.mild:
        if (b == SensitivityLevel.unknown || b == SensitivityLevel.none) {
          return a;
        }
        return b;
      case SensitivityLevel.moderate:
        if (b == SensitivityLevel.unknown || b == SensitivityLevel.none || b == SensitivityLevel.mild) {
          return a;
        }
        return b;
      case SensitivityLevel.severe:
        if (b == SensitivityLevel.unknown ||
            b == SensitivityLevel.none ||
            b == SensitivityLevel.mild ||
            b == SensitivityLevel.moderate) {
          return a;
        }
        return b;
      default:
        throw ArgumentError(a);
    }
  }

  bool operator >(SensitivityLevel other) {
    return (this == SensitivityLevel.unknown || other == SensitivityLevel.unknown) ? false : (toInt() > other.toInt());
  }

  bool operator <(SensitivityLevel other) {
    return (this == SensitivityLevel.unknown || other == SensitivityLevel.unknown) ? false : (toInt() < other.toInt());
  }

  int toInt() {
    switch (this) {
      case SensitivityLevel.unknown:
        return -1;
      case SensitivityLevel.none:
        return 0;
      case SensitivityLevel.mild:
        return 1;
      case SensitivityLevel.moderate:
        return 2;
      case SensitivityLevel.severe:
        return 3;
      default:
        throw ArgumentError(this);
    }
  }

  @override
  int compareTo(SensitivityLevel other) => toInt().compareTo(other.toInt());

  static List<SensitivityLevel> list() {
    return [
      SensitivityLevel.unknown,
      SensitivityLevel.none,
      SensitivityLevel.mild,
      SensitivityLevel.moderate,
      SensitivityLevel.severe,
    ];
  }
}

final _severitySerializer = SeveritySerializer();

class SeveritySerializer implements PrimitiveSerializer<SensitivityLevel> {
  @override
  final Iterable<Type> types = const <Type>[SensitivityLevel];
  @override
  final String wireName = 'SensitivityLevel';

  @override
  Object serialize(Serializers serializers, SensitivityLevel sensitivity,
          {FullType specifiedType = FullType.unspecified}) =>
      sensitivity.toInt();

  @override
  SensitivityLevel deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SensitivityLevel.fromNum(serialized as num);
}
