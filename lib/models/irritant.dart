import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'model_interfaces.dart';

part 'irritant.g.dart';

abstract class Irritant implements Built<Irritant, IrritantBuilder>, Searchable {
  static Serializer<Irritant> get serializer => _$irritantSerializer;

  String get name;

  Irritant._();
  factory Irritant([updates(IrritantBuilder b)]) = _$Irritant;

  String searchHeading() => name;
}
