import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'food_reference/food_reference.dart';
import 'model_interfaces.dart';
import 'sensitivity/sensitivity.dart';
import 'sensitivity/sensitivity_entry.dart';
import 'sensitivity/sensitivity_level.dart';
import 'sensitivity/sensitivity_source.dart';
import 'user_food_details.dart';

part 'user_food_details_api.g.dart';

abstract class UserFoodDetailsApi with Ided, Noted implements Built<UserFoodDetailsApi, UserFoodDetailsApiBuilder> {
  static Serializer<UserFoodDetailsApi> get serializer => _$userFoodDetailsApiSerializer;

  FoodReference get foodReference;

  @BuiltValueField(wireName: 'sensitivity')
  SensitivityLevel? get sensitivityLevel;

  UserFoodDetailsApi._();

  factory UserFoodDetailsApi({
    required String id,
    required FoodReference foodReference,
    SensitivityLevel? sensitivityLevel,
    String? notes,
  }) = _$UserFoodDetailsApi._;

  factory UserFoodDetailsApi.fromBuilder([UserFoodDetailsApiBuilder Function(UserFoodDetailsApiBuilder) updates]) =
      _$UserFoodDetailsApi;

  SensitivityEntry toSensitivityEntry() {
    final sensitivityLevel = this.sensitivityLevel ?? SensitivityLevel.unknown;
    return SensitivityEntry(userFoodDetailsId: id, foodReference: foodReference, sensitivityLevel: sensitivityLevel);
  }

  Sensitivity toSensitivity() {
    final level = sensitivityLevel ?? SensitivityLevel.unknown;
    const source = SensitivitySource.user;
    return Sensitivity(level: level, source: source);
  }

  UserFoodDetails toUserFoodDetails() {
    return UserFoodDetails(userFoodDetailsId: id, foodReference: foodReference, notes: notes);
  }
}
