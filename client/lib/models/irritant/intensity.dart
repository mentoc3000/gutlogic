import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'intensity.g.dart';

class Intensity extends EnumClass implements Comparable<Intensity> {
  static Serializer<Intensity> get serializer => _$intensitySerializer;

  static const Intensity unknown = _$unknown;
  static const Intensity none = _$none;
  static const Intensity trace = _$trace;
  static const Intensity low = _$low;
  static const Intensity medium = _$medium;
  static const Intensity high = _$high;

  const Intensity._(String name) : super(name);

  static BuiltSet<Intensity> get values => _$values;
  static Intensity valueOf(String name) => _$valueOf(name);

  int _toInt() {
    switch (this) {
      case Intensity.unknown:
        return -1;
      case Intensity.none:
        return 0;
      case Intensity.trace:
        return 1;
      case Intensity.low:
        return 2;
      case Intensity.medium:
        return 3;
      case Intensity.high:
        return 4;
      default:
        throw ArgumentError(this);
    }
  }

  bool operator <(Intensity other) => _toInt() < other._toInt();
  bool operator >(Intensity other) => _toInt() > other._toInt();
  bool operator <=(Intensity other) => _toInt() <= other._toInt();
  bool operator >=(Intensity other) => _toInt() >= other._toInt();

  @override
  int compareTo(Intensity other) => _toInt().compareTo(other._toInt());
}
