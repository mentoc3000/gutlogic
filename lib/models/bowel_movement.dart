import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bowel_movement.g.dart';

abstract class BowelMovement
    implements Built<BowelMovement, BowelMovementBuilder> {
  static Serializer<BowelMovement> get serializer => _$bowelMovementSerializer;

  int get type;
  int get volume;

  BowelMovement._();
  factory BowelMovement([updates(BowelMovementBuilder b)]) = _$BowelMovement;
  factory BowelMovement.startingValue() => BowelMovement((b) => b
    ..type = 4
    ..volume = 3);
}
