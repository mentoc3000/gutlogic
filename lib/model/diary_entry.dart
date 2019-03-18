import 'Food.dart';

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
  int consistency;
  int volume;

  BowelMovementEntry({
    DateTime dateTime,
    this.consistency,
    this.volume
  }) : super(dateTime: dateTime);
}

class MedicineEntry extends DiaryEntry {
  String medicine;
  String dose;

  MedicineEntry({
    DateTime dateTime,
    this.medicine,
    this.dose
  }) : super(dateTime: dateTime);
}