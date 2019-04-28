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
    Meal meal,
  }) : super(dateTime: dateTime) {
    this.meal = meal ?? Meal();
  }

  factory MealEntry.newEntry() {
    return MealEntry(
      dateTime: DateTime.now(),
      meal: Meal(name: 'Meal')
    );
  }
}

class BowelMovementEntry extends DiaryEntry {
  BowelMovement bowelMovement;

  BowelMovementEntry({DateTime dateTime, BowelMovement bowelMovement})
      : super(dateTime: dateTime) {
    this.bowelMovement = bowelMovement ?? BowelMovement();
  }
}

class MedicineEntry extends DiaryEntry {
  Medicine medicine;
  String dose;

  MedicineEntry({DateTime dateTime, Medicine medicine, String dose})
      : super(dateTime: dateTime) {
    this.medicine = medicine ?? Medicine();
    this.dose = dose ?? '';
  }
}

class SymptomEntry extends DiaryEntry {
  Symptom symptom;

  SymptomEntry({
    DateTime dateTime,
    Symptom symptom,
  }) : super(dateTime: dateTime) {
    this.symptom = symptom ?? Symptom();
  }
}
