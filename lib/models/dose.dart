import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'quantity.dart';
import 'medicine.dart';

part 'dose.g.dart';

abstract class Dose implements Built<Dose, DoseBuilder> {
  static Serializer<Dose> get serializer => _$doseSerializer;

  Medicine get medicine;
  Quantity get quantity;

  Dose._();
  factory Dose({@required Medicine medicine, @required Quantity quantity}) =
      _$Dose._;
  factory Dose.fromBuilder([updates(DoseBuilder b)]) = _$Dose;
}
