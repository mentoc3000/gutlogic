import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

part 'sensitivity.g.dart';

class Sensitivity extends EnumClass implements Comparable<Sensitivity> {
  @BuiltValueSerializer(custom: true)
  static Serializer<Sensitivity> get serializer => _severitySerializer;

  static const Sensitivity unknown = _$unknown;
  static const Sensitivity none = _$none;
  static const Sensitivity mild = _$mild;
  static const Sensitivity moderate = _$moderate;
  static const Sensitivity severe = _$severe;

  const Sensitivity._(String name) : super(name);

  static BuiltSet<Sensitivity> get values => _$values;
  static Sensitivity valueOf(String name) => _$valueOf(name);
  static Sensitivity fromInt(int i) => Sensitivity.fromNum(i);
  static Sensitivity fromNum(num i) {
    if (i < 0) {
      return Sensitivity.unknown;
    } else if (i < 0.5) {
      return Sensitivity.none;
    } else if (i < 1.5) {
      return Sensitivity.mild;
    } else if (i < 2.5) {
      return Sensitivity.moderate;
    } else {
      return Sensitivity.severe;
    }
  }

  int toInt() {
    switch (this) {
      case Sensitivity.unknown:
        return -1;
      case Sensitivity.none:
        return 0;
      case Sensitivity.mild:
        return 1;
      case Sensitivity.moderate:
        return 2;
      case Sensitivity.severe:
        return 3;
      default:
        throw ArgumentError(this);
    }
  }

  @override
  int compareTo(Sensitivity other) => toInt().compareTo(other.toInt());
}

final _severitySerializer = SeveritySerializer();

class SeveritySerializer implements PrimitiveSerializer<Sensitivity> {
  @override
  final Iterable<Type> types = const <Type>[Sensitivity];
  @override
  final String wireName = 'Sensitivity';

  @override
  Object serialize(Serializers serializers, Sensitivity sensitivity, {FullType specifiedType = FullType.unspecified}) =>
      sensitivity.toInt();

  @override
  Sensitivity deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      Sensitivity.fromNum(serialized as num);
}
