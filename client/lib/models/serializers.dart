import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bowel_movement.dart';
import 'diary_entry/bowel_movement_entry.dart';
import 'diary_entry/diary_entry.dart';
import 'diary_entry/meal_entry.dart';
import 'diary_entry/symptom_entry.dart';
import 'food/custom_food.dart';
import 'food/edamam_food.dart';
import 'food/food.dart';
import 'food_group_entry.dart';
import 'food_reference/custom_food_reference.dart';
import 'food_reference/edamam_food_reference.dart';
import 'food_reference/food_reference.dart';
import 'irritant/intensity_thresholds.dart';
import 'irritant/food_irritants_api.dart';
import 'irritant/irritant.dart';
import 'meal_element.dart';
import 'measure.dart';
import 'pantry/pantry_entry.dart';
import 'quantity.dart';
import 'sensitivity/sensitivity.dart';
import 'sensitivity/sensitivity_entry.dart';
import 'sensitivity/sensitivity_level.dart';
import 'sensitivity/sensitivity_source.dart';
import 'severity.dart';
import 'symptom.dart';
import 'symptom_type.dart';
import 'user/application_user_data.dart';
import 'user_food_details.dart';
import 'user_food_details_api.dart';
import 'user/profile.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApplicationUserData,
  BowelMovement,
  BowelMovementEntry,
  CustomFood,
  CustomFoodReference,
  DiaryEntry,
  EdamamFood,
  EdamamFoodReference,
  Food,
  IntensityThresholds,
  FoodIrritantsApi,
  FoodGroupEntry,
  FoodReference,
  Sensitivity,
  MealElement,
  Measure,
  Irritant,
  MealEntry,
  PantryEntry,
  Profile,
  Quantity,
  SensitivityLevel,
  SensitivityEntry,
  SensitivitySource,
  Severity,
  Symptom,
  SymptomEntry,
  SymptomType,
  UserFoodDetails,
  UserFoodDetailsApi,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(TimestampDateTimeSerializer()))
    .build();

/// Alternative serializer for [DateTime].
///
/// Install this to use ISO8601 format instead of the default (microseconds
/// since epoch). Use [SerializersBuilder.add] to install it.
///
/// An exception will be thrown on attempt to serialize local DateTime
/// instances; you must use UTC.
class TimestampDateTimeSerializer implements PrimitiveSerializer<DateTime> {
  final bool structured = false;

  @override
  final Iterable<Type> types = BuiltList<Type>([DateTime]);

  @override
  final String wireName = 'DateTime';

  @override
  Object serialize(Serializers serializers, DateTime dateTime, {FullType specifiedType = FullType.unspecified}) {
    if (!dateTime.isUtc) {
      throw ArgumentError.value(dateTime, 'dateTime', 'Must be in utc for serialization.');
    }

    return Timestamp.fromDate(dateTime);
  }

  @override
  DateTime deserialize(Serializers serializers, Object serialized, {FullType specifiedType = FullType.unspecified}) {
    return (serialized as Timestamp).toDate().toUtc();
  }
}
