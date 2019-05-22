import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bowel_movement.g.dart';

@JsonSerializable()
class BowelMovement extends Equatable {
  int type;
  int volume;

  BowelMovement({this.type, this.volume});

  factory BowelMovement.fromJson(Map<String, dynamic> json) => _$BowelMovementFromJson(json);

  Map<String, dynamic> toJson() => _$BowelMovementToJson(this);
}
