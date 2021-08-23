import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../food_reference/food_reference.dart';
import '../model_interfaces.dart';
import 'sensitivity.dart';
import 'sensitivity_level.dart';
import 'sensitivity_source.dart';

part 'sensitivity_entry.g.dart';

abstract class SensitivityEntry
    with UserFoodDetail
    implements Built<SensitivityEntry, SensitivityEntryBuilder>, Searchable {
  static Serializer<SensitivityEntry> get serializer => _$sensitivityEntrySerializer;

  FoodReference get foodReference;

  @BuiltValueField(wireName: 'sensitivity')
  SensitivityLevel get sensitivityLevel;

  SensitivityEntry._();

  factory SensitivityEntry({
    required String userFoodDetailsId,
    required FoodReference foodReference,
    required SensitivityLevel sensitivityLevel,
  }) = _$SensitivityEntry._;

  factory SensitivityEntry.fromBuilder([SensitivityEntryBuilder Function(SensitivityEntryBuilder) updates]) =
      _$SensitivityEntry;

  Sensitivity toSensitivity() => Sensitivity(level: sensitivityLevel, source: SensitivitySource.user);

  @override
  String searchHeading() => foodReference.name;

  @override
  String queryText() => foodReference.name;
}
