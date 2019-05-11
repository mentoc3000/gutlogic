class Food {
  String name;
  List<String> irritants;

  Food({this.name, this.irritants});

  factory Food.fromJson(Map<String, dynamic> json) {
    return new Food(
      name: json['name'],
      irritants: json['irritants'],
    );
  }
}
