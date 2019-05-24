import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'quantity.dart';
import 'medicine.dart';

part 'dose.g.dart';

@JsonSerializable()
class Dose extends Equatable {
  Medicine medicine;
  Quantity quantity;

  Dose({this.medicine, this.quantity});

  factory Dose.fromJson(Map<String, dynamic> json) => _$DoseFromJson(json);

  Map<String, dynamic> toJson() => _$DoseToJson(this);
}

List<Dose> dosesFromJson(List<Map<String, dynamic>> json) {
  return json?.map((i) => Dose.fromJson(i))?.toList() ?? [];
}
