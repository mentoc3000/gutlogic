import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import '../bowel_movement.dart';
import 'diary_entry.dart';

part 'bowel_movement_entry.g.dart';

abstract class BowelMovementEntry implements DiaryEntry, Built<BowelMovementEntry, BowelMovementEntryBuilder> {
  static Serializer<BowelMovementEntry> get serializer => _$bowelMovementEntrySerializer;

  BowelMovement get bowelMovement;

  BowelMovementEntry._();

  factory BowelMovementEntry({
    @required String id,
    @required DateTime datetime,
    @required BowelMovement bowelMovement,
    String notes,
  }) = _$BowelMovementEntry._;

  factory BowelMovementEntry.fromBuilder([BowelMovementEntryBuilder Function(BowelMovementEntryBuilder) updates]) =
      _$BowelMovementEntry;
}
