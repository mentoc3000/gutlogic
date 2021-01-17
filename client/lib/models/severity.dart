import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

part 'severity.g.dart';

class Severity extends EnumClass {
  @BuiltValueSerializer(custom: true)
  static Serializer<Severity> get serializer => _severitySerializer;

  static const Severity mild = _$mild;
  static const Severity moderate = _$moderate;
  static const Severity intense = _$intense;
  static const Severity severe = _$severe;

  const Severity._(String name) : super(name);

  static BuiltSet<Severity> get values => _$values;
  static Severity valueOf(String name) => _$valueOf(name);
}

final _severitySerializer = SeveritySerializer();

class SeveritySerializer implements PrimitiveSerializer<Severity> {
  @override
  final Iterable<Type> types = const <Type>[Severity];
  @override
  final String wireName = 'Severity';

  @override
  Object serialize(Serializers serializers, Severity severity, {FullType specifiedType = FullType.unspecified}) {
    switch (severity) {
      case Severity.mild:
        return 1;
      case Severity.moderate:
        return 2;
      case Severity.intense:
        return 3;
      case Severity.severe:
        return 4;
      default:
        throw ArgumentError(severity);
    }
  }

  @override
  Severity deserialize(Serializers serializers, Object serialized, {FullType specifiedType = FullType.unspecified}) {
    final numberSeverity = serialized as num;
    if (numberSeverity < 1.5) {
      return Severity.mild;
    } else if (numberSeverity < 2.5) {
      return Severity.moderate;
    } else if (numberSeverity < 3.5) {
      return Severity.intense;
    } else {
      return Severity.severe;
    }
  }
}
