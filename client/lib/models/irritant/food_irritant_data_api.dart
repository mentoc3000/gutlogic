import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'food_irritant_data_api.g.dart';

abstract class FoodIrritantDataApi implements Built<FoodIrritantDataApi, FoodIrritantDataApiBuilder> {
  static Serializer<FoodIrritantDataApi> get serializer => _$foodIrritantDataApiSerializer;

  /// Irritant name
  String get name;

  /// Dose divisions between intensity levels
  /// Last step indicates highest intensity level
  BuiltList<double> get intensitySteps;

  FoodIrritantDataApi._();

  factory FoodIrritantDataApi.fromBuilder([FoodIrritantDataApiBuilder Function(FoodIrritantDataApiBuilder) updates]) =
      _$FoodIrritantDataApi;
}
