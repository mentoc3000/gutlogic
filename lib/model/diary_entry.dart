import 'food.dart';
import 'bowel_movement.dart';
import 'medicine.dart';
import 'symptom.dart';
import 'meal.dart';

class DiaryEntry {
  DateTime dateTime;

  DiaryEntry({this.dateTime});
}

class MealEntry extends DiaryEntry {
  Meal meal;

  MealEntry({
    DateTime dateTime,
    this.meal,
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