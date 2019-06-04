import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'bowel_movement.dart';
import 'quantity.dart';
import 'medicine.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  BowelMovement,
  Quantity,
  Medicine,
])

final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();