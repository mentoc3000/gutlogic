import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../food_reference/food_reference.dart';
import '../irritant/irritant.dart';
import '../measure.dart';
import '../model_interfaces.dart';

part 'food.g.dart';

@BuiltValue(instantiable: false)
abstract class Food with Ided, Named implements Searchable {
  static BuiltList<Measure> defaultMeasures = <Measure>[].build();

  BuiltList<Measure> get measures;
  String? get brand;
  BuiltList<Irritant>? get irritants;

  FoodReference toFoodReference();
}
