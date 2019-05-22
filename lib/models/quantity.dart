import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quantity.g.dart';

@JsonSerializable()
class Quantity extends Equatable {
  double amount;
  String unit;

  Quantity({this.amount, this.unit});

  factory Quantity.fromJson(Map<String, dynamic> json) =>
    _$QuantityFromJson(json);

  Map<String, dynamic> toJson() => _$QuantityToJson(this);  

  String toString() {
    return amount.toString() + ' ' + unit;
  }
}
