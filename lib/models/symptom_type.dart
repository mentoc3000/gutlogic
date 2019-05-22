import 'package:equatable/equatable.dart';
import 'package:gut_ai/models/model_interfaces.dart';

class SymptomType extends Equatable implements Searchable {

  final String name;

  SymptomType({this.name});

  factory SymptomType.fromJson(Map<String, dynamic> parsedJson) {
    return SymptomType(
      name: parsedJson['name'],
    );
  }

  String searchHeading() {
    return name;
  }
}