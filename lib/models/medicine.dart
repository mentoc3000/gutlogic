import 'package:equatable/equatable.dart';
import 'quantity.dart';

class Medicine extends Equatable {
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
