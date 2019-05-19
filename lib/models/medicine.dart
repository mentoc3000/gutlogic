import 'package:equatable/equatable.dart';
import 'model_interfaces.dart';

class Medicine extends Equatable implements Searchable {
  String name;

  Medicine({
    this.name,
  });

  factory Medicine.fromJson(Map<String, dynamic> parsedJson) {
    return Medicine(
      name: parsedJson['name'],
    );
  }

  String searchHeading() => name;
}
