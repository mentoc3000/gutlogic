import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:gut_ai/models/symptom_type.dart';
import 'bowel_movement.dart';
import 'symptom.dart';
import 'meal.dart';
import 'dose.dart';
import 'model_interfaces.dart';

part 'diary_entry.g.dart';

abstract class DiaryEntry implements DatabaseItem {
  String get id;
  String get userId;
  DateTime get creationDate;
  DateTime get modificationDate;
  DateTime get dateTime;
  String get notes;
}

abstract class MealEntry
    implements Built<MealEntry, MealEntryBuilder>, DiaryEntry {
  static Serializer<MealEntry> get serializer => _$mealEntrySerializer;

  String get id;
  String get userId;
  DateTime get creationDate;
  DateTime get modificationDate;
  DateTime get dateTime;
  Meal get meal;
  String get notes;

  MealEntry._();
  factory MealEntry(
      {@required String id,
      @required String userId,
      @required DateTime creationDate,
      @required DateTime modificationDate,
      @required DateTime dateTime,
      @required Meal meal,
      @required String notes}) = _$MealEntry._;
  factory MealEntry.fromBuilder([updates(MealEntryBuilder b)]) = _$MealEntry;

  factory MealEntry.newEntry(String id, String userId) =>
      MealEntry.fromBuilder((b) {
        DateTime now = DateTime.now();
        return b
          ..id = id
          ..userId = userId
          ..creationDate = now
          ..creationDate = now
          ..dateTime = now
          ..meal = Meal.empty().toBuilder()
          ..notes = '';
      });

  String searchHeading() => 'Meal';
  String queryText() {
    Iterable<String> textParts =
        meal.ingredients.map((i) => i.food.name).toList()..add(notes);
    return textParts.join(' ');
  }
}

abstract class BowelMovementEntry
    implements
        Built<BowelMovementEntry, BowelMovementEntryBuilder>,
        DiaryEntry {
  static Serializer<BowelMovementEntry> get serializer =>
      _$bowelMovementEntrySerializer;

  String get id;
  String get userId;
  DateTime get creationDate;
  DateTime get modificationDate;
  DateTime get dateTime;
  BowelMovement get bowelMovement;
  String get notes;

  BowelMovementEntry._();
  factory BowelMovementEntry(
      {@required String id,
      @required String userId,
      @required DateTime creationDate,
      @required DateTime modificationDate,
      @required DateTime dateTime,
      @required BowelMovement bowelMovement,
      @required String notes}) = _$BowelMovementEntry._;
  factory BowelMovementEntry.fromBuilder(
      [updates(BowelMovementEntryBuilder b)]) = _$BowelMovementEntry;

  factory BowelMovementEntry.newEntry(String id, String userId) =>
      BowelMovementEntry.fromBuilder((b) {
        DateTime now = DateTime.now();
        return b
          ..id = id
          ..userId = userId
          ..creationDate = now
          ..creationDate = now
          ..dateTime = now
          ..bowelMovement = BowelMovement.startingValue().toBuilder()
          ..notes = '';
      });

  String searchHeading() => 'Bowel Movement';
  String queryText() => 'Bowel Movement';
}

abstract class DosesEntry
    implements Built<DosesEntry, DosesEntryBuilder>, DiaryEntry {
  static Serializer<DosesEntry> get serializer => _$dosesEntrySerializer;

  String get id;
  String get userId;
  DateTime get creationDate;
  DateTime get modificationDate;
  DateTime get dateTime;
  BuiltList<Dose> get doses;
  String get notes;

  DosesEntry._();
  factory DosesEntry(
      {@required String id,
      @required String userId,
      @required DateTime creationDate,
      @required DateTime modificationDate,
      @required DateTime dateTime,
      @required BuiltList<Dose> doses,
      @required String notes}) = _$DosesEntry._;
  factory DosesEntry.fromBuilder([updates(DosesEntryBuilder b)]) = _$DosesEntry;

  factory DosesEntry.newEntry(String id, String userId) =>
      DosesEntry.fromBuilder((b) {
        DateTime now = DateTime.now();
        return b
          ..id = id
          ..userId = userId
          ..creationDate = now
          ..creationDate = now
          ..dateTime = now
          ..doses = BuiltList<Dose>([]).toBuilder()
          ..notes = '';
      });

  String searchHeading() => 'Medicine';
  String queryText() {
    Iterable<String> textParts = doses.map((d) => d.medicine.name).toList()
      ..add(notes);
    return textParts.join(' ');
  }
}

abstract class SymptomEntry
    implements Built<SymptomEntry, SymptomEntryBuilder>, DiaryEntry {
  static Serializer<SymptomEntry> get serializer => _$symptomEntrySerializer;

  String get id;
  String get userId;
  DateTime get creationDate;
  DateTime get modificationDate;
  DateTime get dateTime;
  Symptom get symptom;
  String get notes;

  SymptomEntry._();
  factory SymptomEntry(
      {@required String id,
      @required String userId,
      @required DateTime creationDate,
      @required DateTime modificationDate,
      @required DateTime dateTime,
      @required Symptom symptom,
      @required String notes}) = _$SymptomEntry._;
  factory SymptomEntry.fromBuilder([updates(SymptomEntryBuilder b)]) =
      _$SymptomEntry;

  factory SymptomEntry.newEntry(String id, String userId) =>
      SymptomEntry.fromBuilder((b) {
        DateTime now = DateTime.now();
        return b
          ..id = id
          ..userId = userId
          ..creationDate = now
          ..creationDate = now
          ..dateTime = now
          // TODO: Why does this need to be converted to a builder?
          ..symptom.symptomType =
              SymptomType.fromBuilder((b) => b.name = '').toBuilder()
          ..symptom.severity = 5
          ..notes = '';
      });

  String searchHeading() => 'Symptom';
  String queryText() {
    return [symptom.symptomType.name, notes].join(' ');
  }
}
