import 'bowel_movement.dart';
import 'symptom.dart';
import 'meal.dart';
import 'dose.dart';

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

class DosesEntry extends DiaryEntry {
  List<Dose> doses;

  DosesEntry({DateTime dateTime, List<Dose> doses})
      : super(dateTime: dateTime) {
    this.doses = doses ?? [];
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
