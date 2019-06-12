import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quantity.g.dart';

abstract class Quantity implements Built<Quantity, QuantityBuilder> {
  static Serializer<Quantity> get serializer => _$quantitySerializer;

  double get amount;
  String get unit;

  Quantity._();
  factory Quantity({double amount, String unit}) = _$Quantity._;
  factory Quantity.fromBuilder([updates(QuantityBuilder b)]) = _$Quantity;
}
