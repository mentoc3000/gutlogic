import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'irritant.dart';

part 'food_irritants_api.g.dart';

abstract class FoodIrritantsApi implements Built<FoodIrritantsApi, FoodIrritantsApiBuilder> {
  static Serializer<FoodIrritantsApi> get serializer => _$foodIrritantsApiSerializer;

  /// Food name
  BuiltList<String> get names;

  /// Edamam food ids associated with the food
  BuiltList<String> get foodIds;

  BuiltList<Irritant> get irritants;

  FoodIrritantsApi._();

  factory FoodIrritantsApi.fromBuilder([FoodIrritantsApiBuilder Function(FoodIrritantsApiBuilder) updates]) =
      _$FoodIrritantsApi;
}
