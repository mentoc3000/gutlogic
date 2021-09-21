import 'package:built_value/built_value.dart';

import '../model_interfaces.dart';

part 'food_reference.g.dart';

@BuiltValue(instantiable: false)
abstract class FoodReference with Ided, Named implements Searchable {}
