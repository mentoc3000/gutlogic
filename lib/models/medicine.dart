import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'model_interfaces.dart';

part 'medicine.g.dart';

@JsonSerializable()
class Medicine extends Equatable implements Searchable {
  String name;

  Medicine({
    this.name,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) =>
      _$MedicineFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineToJson(this);

  String searchHeading() => name;
}
