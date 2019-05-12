import 'package:equatable/equatable.dart';

class BowelMovement extends Equatable {
  int type;
  int volume;

  BowelMovement({this.type, this.volume});

  factory BowelMovement.fromJson(Map<String, dynamic> parsedJson) {
    return BowelMovement(
      type: parsedJson['type'],
      volume: parsedJson['volume'],
    );
  }
}
