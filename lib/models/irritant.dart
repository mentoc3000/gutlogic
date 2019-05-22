import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'model_interfaces.dart';

part 'irritant.g.dart';

@JsonSerializable()
class Irritant extends Equatable implements Searchable{
  String name;

  Irritant({this.name});

  factory Irritant.fromJson(Map<String, dynamic> json) =>
      _$IrritantFromJson(json);

  Map<String, dynamic> toJson() => _$IrritantToJson(this);

  String searchHeading() => name;
}
