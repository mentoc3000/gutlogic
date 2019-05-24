import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'bowel_movement.dart';
import 'symptom.dart';
import 'meal.dart';
import 'dose.dart';

part 'diary_entry.g.dart';

class DiaryEntry extends Equatable {
  DateTime dateTime;
  String notes;

  DiaryEntry({this.dateTime, this.notes = ''});
}

@JsonSerializable()
class MealEntry extends DiaryEntry {
  Meal meal;

  MealEntry({
    DateTime dateTime,
    Meal meal,
    String notes,
  }) : super(
          dateTime: dateTime,
          notes: notes,
        ) {
    this.meal = meal ?? Meal();
  }

  factory MealEntry.newEntry() {
    return MealEntry(dateTime: DateTime.now(), meal: Meal(name: 'Meal'));
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) =>
      _$MealEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MealEntryToJson(this);
}

@JsonSerializable()
class BowelMovementEntry extends DiaryEntry {
  BowelMovement bowelMovement;

  BowelMovementEntry({
    DateTime dateTime,
    BowelMovement bowelMovement,
    String notes,
  }) : super(
          dateTime: dateTime,
          notes: notes,
        ) {
    this.bowelMovement = bowelMovement ?? BowelMovement();
  }

  factory BowelMovementEntry.fromJson(Map<String, dynamic> json) =>
      _$BowelMovementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$BowelMovementEntryToJson(this);
}

@JsonSerializable()
class DosesEntry extends DiaryEntry {
  @JsonKey(fromJson: dosesFromJson)
  List<Dose> doses;

  DosesEntry({
    DateTime dateTime,
    List<Dose> doses,
    String notes,
  }) : super(
          dateTime: dateTime,
          notes: notes,
        ) {
    this.doses = doses ?? [];
  }

  factory DosesEntry.fromJson(Map<String, dynamic> json) =>
      _$DosesEntryFromJson(json);

  Map<String, dynamic> toJson() => _$DosesEntryToJson(this);
}

@JsonSerializable()
class SymptomEntry extends DiaryEntry {
  Symptom symptom;

  SymptomEntry({
    DateTime dateTime,
    Symptom symptom,
    String notes,
  }) : super(
          dateTime: dateTime,
          notes: notes,
        ) {
    this.symptom = symptom ?? Symptom();
  }

  factory SymptomEntry.fromJson(Map<String, dynamic> json) =>
      _$SymptomEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomEntryToJson(this);
}
