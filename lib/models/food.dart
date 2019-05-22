import 'package:equatable/equatable.dart';
import 'model_interfaces.dart';
import 'irritant.dart';

class Food extends Equatable implements Searchable{
  String name;
  List<Irritant> irritants;

  Food({this.name, this.irritants});

  factory Food.fromJson(Map<String, dynamic> json) {
    return new Food(
      name: json['name'],
      irritants: json['irritants'],
    );
  }

  String searchHeading() => name;
}
