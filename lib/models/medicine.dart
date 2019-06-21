import 'package:meta/meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'model_interfaces.dart';

part 'medicine.g.dart';

abstract class Medicine implements Built<Medicine, MedicineBuilder>, Searchable, DatabaseItem {
  static Serializer<Medicine> get serializer => _$medicineSerializer;

  @nullable String get id;
  String get name;

  Medicine._();
  factory Medicine({String id, @required String name}) = _$Medicine._;
  factory Medicine.fromBuilder([updates(MedicineBuilder b)]) = _$Medicine;

  String searchHeading() => name;
  String queryText() => name;
}
