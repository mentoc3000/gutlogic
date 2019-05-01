import 'quantity.dart';
import 'medicine.dart';

class Dose {
  Medicine medicine;
  Quantity quantity;

  Dose({
    this.medicine,
    this.quantity
  });
}