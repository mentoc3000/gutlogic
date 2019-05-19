import 'package:equatable/equatable.dart';
import 'quantity.dart';
import 'medicine.dart';

class Dose extends Equatable {
  Medicine medicine;
  Quantity quantity;

  Dose({this.medicine, this.quantity});

  factory Dose.copy(Dose original) {
    return Dose(medicine: original.medicine, quantity: original.quantity);
  }

  factory Dose.fromJson(Map<String, dynamic> parsedJson) {
    return Dose(
      medicine: Medicine.fromJson(parsedJson['type']),
      quantity: Quantity.fromJson(parsedJson['volume']),
    );
  }
}
