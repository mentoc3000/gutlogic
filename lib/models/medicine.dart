import 'quantity.dart';

class Medicine {
  String name;

  Medicine({
    this.name,
  });

  factory Medicine.fromJson(Map<String, dynamic> parsedJson) {
    return Medicine(
      name: parsedJson['name'],
    );
  }
}
