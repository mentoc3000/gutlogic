class BowelMovement {
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
