import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'bowel_movement.dart';
import 'quantity.dart';
import 'medicine.dart';
import 'symptom_type.dart';
import 'symptom.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  BowelMovement,
  Quantity,
  Medicine,
  SymptomType,
  Symptom,
])

final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();