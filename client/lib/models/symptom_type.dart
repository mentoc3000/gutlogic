import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'model_interfaces.dart';

part 'symptom_type.g.dart';

abstract class SymptomType with Ided, Named implements Built<SymptomType, SymptomTypeBuilder>, Searchable {
  static Serializer<SymptomType> get serializer => _$symptomTypeSerializer;

  SymptomType._();

  factory SymptomType({@required String id, @required String name}) = _$SymptomType._;

  factory SymptomType.fromBuilder([SymptomTypeBuilder Function(SymptomTypeBuilder) updates]) = _$SymptomType;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;
}
