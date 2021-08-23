import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'food_reference/food_reference.dart';
import 'model_interfaces.dart';

part 'user_food_details.g.dart';

abstract class UserFoodDetails
    with UserFoodDetail, Noted
    implements Built<UserFoodDetails, UserFoodDetailsBuilder>, Searchable {
  static Serializer<UserFoodDetails> get serializer => _$userFoodDetailsSerializer;

  FoodReference get foodReference;

  UserFoodDetails._();

  factory UserFoodDetails({
    required String userFoodDetailsId,
    required FoodReference foodReference,
    String? notes,
  }) = _$UserFoodDetails._;

  factory UserFoodDetails.fromBuilder([UserFoodDetailsBuilder Function(UserFoodDetailsBuilder) updates]) =
      _$UserFoodDetails;

  @override
  String searchHeading() => foodReference.name;

  @override
  String queryText() => foodReference.name;
}
