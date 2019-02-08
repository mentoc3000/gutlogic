import 'Irritant.dart';

class IrritantList {
  List<Irritant> irritants = new List();

  IrritantList({
    this.irritants
  });

  factory IrritantList.fromJson(List<dynamic> parsedJson) {
    List<Irritant> irritants = new List<Irritant>();

    irritants = parsedJson.map((i) => Irritant.fromJson(i)).toList();

    return new IrritantList(irritants: irritants);
  }
}