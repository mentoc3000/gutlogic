import 'package:equatable/equatable.dart';
import 'model_interfaces.dart';
import 'irritant.dart';

class Food extends Equatable implements Searchable{
  String name;
  List<Irritant> irritants;

  Food({this.name, irritants}) {
    this.irritants = irritants ?? [];
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> irritantJson = json['irritants'];
    return new Food(
      name: json['name'],
      irritants: irritantJson.map((i) => Irritant.fromJson(i)).toList(),
    );
  }

  String searchHeading() => name;
}
