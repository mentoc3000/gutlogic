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
    return edamamEntries.map((foods) => foods.map((f) => f.toEdamamFood()).whereNotNull().toBuiltList());
  }

  Future<BuiltList<EdamamFood>> fetchQuery(String query) => streamQuery(query).first;

  Stream<EdamamFood?> streamFood(EdamamFoodReference foodReference) {
    final edamamEntry = Stream.fromFuture(edamamService.getById(foodReference.id));
    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific one.
    return edamamEntry.map((e) => e?.toEdamamFood()?.rebuild((b) => b.name = foodReference.name));
  }

  Future<EdamamFood?> fetchFood(EdamamFoodReference foodReference) => streamFood(foodReference).first;
}
