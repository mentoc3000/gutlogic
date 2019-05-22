import 'package:equatable/equatable.dart';
import 'model_interfaces.dart';

class Irritant extends Equatable implements Searchable{
  String name;

  Irritant({this.name});

  factory Irritant.fromJson(Map<String, dynamic> json) {
    return new Irritant(
      name: json['name'],
    );
  }

  String searchHeading() => name;
}
