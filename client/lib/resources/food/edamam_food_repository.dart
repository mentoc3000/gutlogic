import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/food/edamam_food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../food/edamam_service.dart';
import 'food_repository.dart';

class EdamamFoodRepository implements FoodRepository {
  final EdamamService edamamService;

  EdamamFoodRepository({required this.edamamService});

  @override
  Future<BuiltList<EdamamFood>> fetchQuery(String query) async {
    if (query.isEmpty) return <EdamamFood>[].build();
    final edamamEntry = await edamamService.searchFood(query);
    return BuiltList<EdamamFood>(edamamEntry.map((f) => f.toEdamamFood()));
  }

  Future<EdamamFood?> fetchItem(EdamamFoodReference foodReference) async {
    final edamamEntry = await edamamService.getById(foodReference.id);
    final edamamFood = edamamEntry?.toEdamamFood();

    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific one.
    return edamamFood?.rebuild((b) => b.name = foodReference.name);
  }

  @override
  Stream<BuiltList<EdamamFood>> streamQuery(String query) => Stream.fromFuture(fetchQuery(query));
}
