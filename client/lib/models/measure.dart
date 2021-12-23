import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'measure.g.dart';

abstract class Measure implements Built<Measure, MeasureBuilder> {
  @BuiltValueSerializer(custom: true)
  static Serializer<Measure> get serializer => _measureSerializer;

  String get unit;

  // EdamamFoods will have measure with weights to allow for unit conversion, but CustomFoods will only have the unit.
  double? get weight; // in grams

  Measure._();

  factory Measure({required String unit, double weight}) = _$Measure._;

  factory Measure.fromBuilder([MeasureBuilder Function(MeasureBuilder) updates]) = _$Measure;

  factory Measure.empty() => Measure(unit: '');

  @override
  String toString() => '$unit ($weight g)';
}

final _measureSerializer = MeasureSerializer();

class MeasureSerializer implements StructuredSerializer<Measure> {
  @override
  final Iterable<Type> types = const [Measure, _$Measure];

  @override
  final String wireName = 'Measure';

  @override
  Iterable<Object?> serialize(Serializers serializers, Measure object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'unit',
      serializers.serialize(object.unit, specifiedType: const FullType(String)),
    ];
    if (object.weight != null) {
      result
        ..add('weight')
        ..add(serializers.serialize(object.weight, specifiedType: const FullType(double)));
    }
    return result;
  }

  @override
  Measure deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = MeasureBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'label': // Edamam uses 'label' for the unit
        case 'unit':
          result.unit = serializers.deserialize(value, specifiedType: const FullType(String)) as String;
          break;
        case 'weight':
          result.weight = serializers.deserialize(value, specifiedType: const FullType(double)) as double;
          break;
      }
    }

    return result.build();
  }
}
