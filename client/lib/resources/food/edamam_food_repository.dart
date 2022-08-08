import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/food/edamam_food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../util/null_utils.dart';
import '../food/edamam_service.dart';

class EdamamFoodRepository {
  final EdamamService edamamService;

  EdamamFoodRepository({required this.edamamService});

  Stream<BuiltList<EdamamFood>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<EdamamFood>[].build());

    final edamamEntries = Stream.fromFuture(edamamService.searchFood(query));
    return edamamEntries.map((foods) => foods.whereNotNull().toBuiltList());
  }

  Stream<EdamamFood?> streamFood(EdamamFoodReference? foodReference) async* {
    if (foodReference == null) yield null;
    final edamamFood = await edamamService.getById(foodReference!.id);
    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific one.
    yield edamamFood?.rebuild((b) => b.name = foodReference.name) ??
        // edamamEntry is null if food no longer exists in Edamam database. Use data from foodReference.
        EdamamFood(id: foodReference.id, name: foodReference.name);
  }
}
