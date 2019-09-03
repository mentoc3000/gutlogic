import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'dose.dart';

part 'dosage.g.dart';

abstract class Dosage implements Built<Dosage, DosageBuilder> {
  static Serializer<Dosage> get serializer => _$dosageSerializer;

  BuiltList<Dose> get doses;

  Dosage._();
  factory Dosage({@required BuiltList<Dose> doses}) = _$Dosage._;
  factory Dosage.fromBuilder([updates(DosageBuilder b)]) = _$Dosage;
  factory Dosage.empty() => Dosage.fromBuilder(
      (b) => b..doses = BuiltList<Dose>([]).toBuilder());
}
