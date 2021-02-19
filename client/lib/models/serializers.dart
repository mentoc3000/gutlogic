import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_provider.dart';
import 'application_user.dart';
import 'bowel_movement.dart';
import 'diary_entry/bowel_movement_entry.dart';
import 'diary_entry/diary_entry.dart';
import 'diary_entry/meal_entry.dart';
import 'diary_entry/symptom_entry.dart';
import 'food/custom_food.dart';
import 'food/edamam_food.dart';
import 'food/food.dart';
import 'food_reference/custom_food_reference.dart';
import 'food_reference/edamam_food_reference.dart';
import 'food_reference/food_reference.dart';
import 'irritant.dart';
import 'meal_element.dart';
import 'measure.dart';
import 'pantry_entry.dart';
import 'quantity.dart';
import 'sensitivity.dart';
import 'severity.dart';
import 'symptom.dart';
import 'symptom_type.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApplicationUser,
  BowelMovement,
  BowelMovementEntry,
  CustomFood,
  CustomFoodReference,
  DiaryEntry,
  EdamamFood,
  EdamamFoodReference,
  Food,
  FoodReference,
  MealElement,
  Measure,
  Irritant,
  MealEntry,
  PantryEntry,
  Quantity,
  Sensitivity,
  Severity,
  Symptom,
  SymptomEntry,
  SymptomType,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(TimestampDateTimeSerializer())
      ..add(AuthProviderSerializer()))
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

class AuthProviderSerializer implements PrimitiveSerializer<AuthProvider> {
  final bool structured = false;

  @override
  final Iterable<Type> types = BuiltList<Type>([AuthProvider]);

  @override
  final String wireName = 'AuthProvider';

  @override
  Object serialize(Serializers serializers, AuthProvider provider, {FullType specifiedType = FullType.unspecified}) {
    return toFirebaseProviderID(provider);
  }

  @override
  AuthProvider deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return fromFirebaseProviderID(serialized as String);
  }
}
