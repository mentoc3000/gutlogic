import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'model_interfaces.dart';
import 'irritant.dart';

part 'food.g.dart';

@JsonSerializable()
class Food extends Equatable implements Searchable{
  String name;
  List<Irritant> irritants;

  Food({this.name, irritants}) {
    this.irritants = irritants ?? [];
  }

  factory Food.fromJson(Map<String, dynamic> json) =>
      _$FoodFromJson(json);

  Map<String, dynamic> toJson() => _$FoodToJson(this);

  String searchHeading() => name;
}
