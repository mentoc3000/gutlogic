import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import '../meal_element.dart';
import 'diary_entry.dart';

part 'meal_entry.g.dart';

abstract class MealEntry implements DiaryEntry, Built<MealEntry, MealEntryBuilder> {
  static Serializer<MealEntry> get serializer => _$mealEntrySerializer;

  BuiltList<MealElement> get mealElements;

  MealEntry._();

  factory MealEntry({
    @required String id,
    @required DateTime datetime,
    @required BuiltList<MealElement> mealElements,
    String notes,
  }) = _$MealEntry._;

  factory MealEntry.fromBuilder([MealEntryBuilder Function(MealEntryBuilder) updates]) = _$MealEntry;
}
