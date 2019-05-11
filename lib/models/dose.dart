import 'quantity.dart';
import 'medicine.dart';

class Dose {
  Medicine medicine;
  Quantity quantity;

  Dose({this.medicine, this.quantity});

  factory Dose.fromJson(Map<String, dynamic> parsedJson) {
    return Dose(
      medicine: Medicine.fromJson(parsedJson['type']),
      quantity: Quantity.fromJson(parsedJson['volume']),
    );
  }
}
