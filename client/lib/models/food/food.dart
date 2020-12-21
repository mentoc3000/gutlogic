import 'package:built_value/built_value.dart';

import '../food_reference/food_reference.dart';
import '../model_interfaces.dart';

part 'food.g.dart';

@BuiltValue(instantiable: false)
abstract class Food with Ided, Named implements Searchable {
  FoodReference toFoodReference();
}
