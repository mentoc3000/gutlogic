import 'package:equatable/equatable.dart';

class Quantity extends Equatable {
  double amount;
  String unit;

  Quantity({
    this.amount,
    this.unit
  });

  factory Quantity.fromJson(Map<String, dynamic> parsedJson) {
    return Quantity(
      amount: parsedJson['amount'],
      unit: parsedJson['unit'],
    );
  }
}