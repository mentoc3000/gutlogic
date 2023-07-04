import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/food/edamam_food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../util/null_utils.dart';
import '../food/edamam_service.dart';
import '../irritant_service.dart';
import '../local_storage.dart';

class EdamamFoodRepository {
  final EdamamService edamamService;
  final LocalStorage localStorage;
  final IrritantService irritantService;

  EdamamFoodRepository({required this.edamamService, required this.localStorage, required this.irritantService});

  Stream<BuiltList<EdamamFood>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<EdamamFood>[].build());

    final edamamEntries = Stream.fromFuture(edamamService.searchFood(query));
    return edamamEntries.map((foods) => foods.whereNotNull().toBuiltList());
  }

  Stream<EdamamFood?> streamFood(EdamamFoodReference? foodReference) async* {
    if (foodReference == null) yield null;

    late final EdamamFood? edamamFood;
    try {
      edamamFood = await edamamService.getById(foodReference!.id);
      if (edamamFood != null) _cacheEdamamFood(edamamFood);
    } catch (e) {
      // Fallback to local storage
      final localFood = await localStorage.getEdamamFood(foodReference!.id);
      if (localFood != null) {
        edamamFood = localFood;
      } else {
        // See if food is in the elementary foods list
        final elementaryFood = await irritantService.getElementaryFood(foodReference.id);
        if (elementaryFood != null) {
          edamamFood = EdamamFood(id: foodReference.id, name: foodReference.name, irritants: elementaryFood.irritants);
        } else {
          // If the food is not in the elementary foods list, give up
          rethrow;
        }
      }
    }

    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific one.
    yield edamamFood?.rebuild((b) => b.name = foodReference.name) ??
        // edamamEntry is null if food no longer exists in Edamam database. Use data from foodReference.
        EdamamFood(id: foodReference.id, name: foodReference.name);
  }

  Stream<EdamamFood?> streamUpc(String upc) {
    return Stream.fromFuture(edamamService.getByUpc(upc));
  }

  void _cacheEdamamFood(EdamamFood food) async {
    // Retain only the data that is allowed to be cached.
    final saveableFood = EdamamFood(id: food.id, name: food.name, irritants: food.irritants);
    localStorage.cacheEdamamFood(saveableFood);
  }
}
