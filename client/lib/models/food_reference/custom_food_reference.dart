import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../model_interfaces.dart';
import 'food_reference.dart';

part 'custom_food_reference.g.dart';

abstract class CustomFoodReference
    implements FoodReference, Built<CustomFoodReference, CustomFoodReferenceBuilder>, Searchable {
  static Serializer<CustomFoodReference> get serializer => _$customFoodReferenceSerializer;

  CustomFoodReference._();

  factory CustomFoodReference({
    required String id,
    required String name,
  }) = _$CustomFoodReference._;

  factory CustomFoodReference.fromBuilder([CustomFoodReferenceBuilder Function(CustomFoodReferenceBuilder) updates]) =
      _$CustomFoodReference;

  @override
  String searchHeading() => name;

  @override
  String queryText() => name;
}
