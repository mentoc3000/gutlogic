import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import '../symptom.dart';
import 'diary_entry.dart';

part 'symptom_entry.g.dart';

abstract class SymptomEntry implements DiaryEntry, Built<SymptomEntry, SymptomEntryBuilder> {
  static Serializer<SymptomEntry> get serializer => _$symptomEntrySerializer;

  Symptom get symptom;

  SymptomEntry._();

  factory SymptomEntry({
    @required String id,
    @required DateTime datetime,
    @required Symptom symptom,
    String notes,
  }) = _$SymptomEntry._;

  factory SymptomEntry.fromBuilder([SymptomEntryBuilder Function(SymptomEntryBuilder) updates]) = _$SymptomEntry;
}
