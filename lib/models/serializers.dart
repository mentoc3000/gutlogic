import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'bowel_movement.dart';
import 'diary_entry.dart';
import 'dosage.dart';
import 'dose.dart';
import 'food.dart';
import 'ingredient.dart';
import 'irritant.dart';
import 'meal.dart';
import 'medicine.dart';
import 'quantity.dart';
import 'symptom_type.dart';
import 'symptom.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  BowelMovement,
  BowelMovementEntry,
  Dosage,
  DosageEntry,
  Dose,
  Food,
  Ingredient,
  Irritant,
  Meal,
  MealEntry,
  Medicine,
  Quantity,
  Symptom,
  SymptomEntry,
  SymptomType,
])

final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();