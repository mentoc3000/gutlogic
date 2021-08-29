import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../models/food_reference/custom_food_reference.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/food_reference/food_reference.dart';
import '../searchable_repository.dart';
import 'custom_food_repository.dart';
import 'edamam_food_repository.dart';

class FoodService implements SearchableRepository<Food> {
  final CustomFoodRepository customFoodRepository;
  final EdamamFoodRepository edamamFoodRepository;

  FoodService({required this.edamamFoodRepository, required this.customFoodRepository});

  Stream<Food?> streamFood(FoodReference? foodReference) {
    if (foodReference == null) return Stream.value(null);

    if (foodReference is EdamamFoodReference) {
      return edamamFoodRepository.streamFood(foodReference);
    } else if (foodReference is CustomFoodReference) {
      return customFoodRepository.streamFood(foodReference);
    } else {
      throw TypeError();
    }
  }

  @override
  Stream<BuiltList<Food>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<CustomFood>[].build());

    final customFoodStream = customFoodRepository.streamQuery(query);
    final edamamFoodStream = edamamFoodRepository.streamQuery(query);

    return CombineLatestStream([customFoodStream, edamamFoodStream], _combineFoodLists);
  }

  Future<CustomFood?> add({required String name}) => customFoodRepository.add(name: name);

  Future<void> delete(CustomFood? food) async {
    if (food != null) {
      await customFoodRepository.delete(food);
    }
  }
}

BuiltList<Food> _combineFoodLists(Iterable<Iterable<Food>> values) {
  final customFoods = values.first;
  final edamamFoods = values.last;
  return [...customFoods, ...edamamFoods].toBuiltList();
}
