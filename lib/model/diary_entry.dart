import 'food.dart';
import 'bowel_movement.dart';
import 'medicine.dart';
import 'symptom.dart';

class DiaryEntry {
  DateTime dateTime;

  DiaryEntry({this.dateTime});
}

class FoodAndDrinkEntry extends DiaryEntry {
  Food food;
  String quantity;

  FoodAndDrinkEntry({
    DateTime dateTime,
    this.food,
    this.quantity
  }) : super(dateTime: dateTime);
}

class BowelMovementEntry extends DiaryEntry {
  BowelMovement bowelMovement;

  BowelMovementEntry({
    DateTime dateTime,
    this.bowelMovement
  }) : super(dateTime: dateTime);
}

class MedicineEntry extends DiaryEntry {
  Medicine medicine;
  String dose;

  MedicineEntry({
    DateTime dateTime,
    this.medicine,
    this.dose
  }) : super(dateTime: dateTime);
}