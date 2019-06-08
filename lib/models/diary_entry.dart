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
  String get notes;
  Meal get meal;

  MealEntry._();
  factory MealEntry([updates(MealEntryBuilder b)]) = _$MealEntry;

  factory MealEntry.newEntry() => MealEntry((b) => b
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
  String get notes;
  BowelMovement get bowelMovement;

  BowelMovementEntry._();
  factory BowelMovementEntry([updates(BowelMovementEntryBuilder b)]) =
      _$BowelMovementEntry;

  factory BowelMovementEntry.newEntry() => BowelMovementEntry((b) => b
    ..dateTime = DateTime.now()
    ..bowelMovement = BowelMovement.startingValue().toBuilder()
    ..notes = '');
}

abstract class DosesEntry implements Built<DosesEntry, DosesEntryBuilder> {
  static Serializer<DosesEntry> get serializer => _$dosesEntrySerializer;

  DateTime get dateTime;
  String get notes;
  BuiltList<Dose> get doses;

  DosesEntry._();
  factory DosesEntry([updates(DosesEntryBuilder b)]) = _$DosesEntry;

  factory DosesEntry.newEntry() => DosesEntry((b) => b
    ..dateTime = DateTime.now()
    ..doses = BuiltList<Dose>([]).toBuilder()
    ..notes = '');
}

abstract class SymptomEntry implements Built<SymptomEntry, SymptomEntryBuilder> {
  static Serializer<SymptomEntry> get serializer => _$symptomEntrySerializer;

  DateTime get dateTime;
  String get notes;
  Symptom get symptom;

  SymptomEntry._();
  factory SymptomEntry([updates(SymptomEntryBuilder b)]) = _$SymptomEntry;

  factory SymptomEntry.newEntry() => SymptomEntry((b) => b
    ..dateTime = DateTime.now()
    ..symptom.symptomType = SymptomType((b) => b.name = '').toBuilder()
    ..symptom.severity = 5
    ..notes = '');
}
