import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gut_ai/models/model_interfaces.dart';

part 'symptom_type.g.dart';

@JsonSerializable()
class SymptomType extends Equatable implements Searchable {

  final String name;

  SymptomType({this.name});

  factory SymptomType.fromJson(Map<String, dynamic> json) =>
      _$SymptomTypeFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomTypeToJson(this);

  String searchHeading() {
    return name;
  }
}