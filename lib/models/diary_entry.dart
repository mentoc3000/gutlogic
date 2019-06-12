import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'bowel_movement.dart';
import 'symptom.dart';
import 'meal.dart';
import 'dose.dart';

part 'diary_entry.g.dart';

abstract class DiaryEntry {
  DateTime get dateTime;
  String get notes;
}

abstract class MealEntry
    implements Built<MealEntry, MealEntryBuilder>, DiaryEntry {
  static Serializer<MealEntry> get serializer => _$mealEntrySerializer;

  DateTime get dateTime;
  Meal get meal;
  String get notes;

  MealEntry._();
  factory MealEntry({DateTime dateTime, Meal meal, String notes}) =
      _$MealEntry._;
  factory MealEntry.fromBuilder([updates(MealEntryBuilder b)]) = _$MealEntry;

  factory MealEntry.newEntry() => MealEntry.fromBuilder((b) => b
    ..dateTime = DateTime.now()
    ..meal = Meal.empty().toBuilder()
    ..notes = '');
}

abstract class BowelMovementEntry
    implements
        Built<BowelMovementEntry, BowelMovementEntryBuilder>,
        DiaryEntry {
  static Serializer<BowelMovementEntry> get serializer =>
      _$bowelMovementEntrySerializer;

  DateTime get dateTime;
  BowelMovement get bowelMovement;
  String get notes;

  BowelMovementEntry._();
  factory BowelMovementEntry(
      {DateTime dateTime,
      BowelMovement bowelMovement,
      String notes}) = _$BowelMovementEntry._;
  factory BowelMovementEntry.fromBuilder(
      [updates(BowelMovementEntryBuilder b)]) = _$BowelMovementEntry;

  factory BowelMovementEntry.newEntry() =>
      BowelMovementEntry.fromBuilder((b) => b
        ..dateTime = DateTime.now()
        ..bowelMovement = BowelMovement.startingValue().toBuilder()
        ..notes = '');
}

abstract class DosesEntry implements Built<DosesEntry, DosesEntryBuilder> {
  static Serializer<DosesEntry> get serializer => _$dosesEntrySerializer;

  DateTime get dateTime;
  BuiltList<Dose> get doses;
  String get notes;

  DosesEntry._();
  factory DosesEntry({DateTime dateTime, BuiltList<Dose> doses, String notes}) =
      _$DosesEntry._;
  factory DosesEntry.fromBuilder([updates(DosesEntryBuilder b)]) = _$DosesEntry;

  factory DosesEntry.newEntry() => DosesEntry.fromBuilder((b) => b
    ..dateTime = DateTime.now()
    ..doses = BuiltList<Dose>([]).toBuilder()
    ..notes = '');
}

abstract class SymptomEntry
    implements Built<SymptomEntry, SymptomEntryBuilder> {
  static Serializer<SymptomEntry> get serializer => _$symptomEntrySerializer;

  DateTime get dateTime;
  Symptom get symptom;
  String get notes;

  SymptomEntry._();
  factory SymptomEntry({DateTime dateTime, Symptom symptom, String notes}) =
      _$SymptomEntry._;
  factory SymptomEntry.fromBuilder([updates(SymptomEntryBuilder b)]) =
      _$SymptomEntry;

  factory SymptomEntry.newEntry() => SymptomEntry.fromBuilder((b) => b
    ..dateTime = DateTime.now()
    ..symptom.symptomType = SymptomType((b) => b.name = '').toBuilder()
    ..symptom.severity = 5
    ..notes = '');
}
