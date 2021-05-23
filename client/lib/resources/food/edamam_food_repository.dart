import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/food/edamam_food.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../food/edamam_service.dart';
import '../pantry_repository.dart';
import 'food_repository.dart';

class EdamamFoodRepository extends FoodRepository<EdamamFood> {
  final EdamamService edamamService;

  EdamamFoodRepository({required this.edamamService, required PantryRepository pantryRepository}) {
    this.pantryRepository = pantryRepository;
  }

  @override
  Stream<BuiltList<EdamamFood>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<EdamamFood>[].build());

    final edamamEntries = Stream.fromFuture(edamamService.searchFood(query));
    final maybeEdamamFoods = edamamEntries.map((foods) => foods.map((f) => f.toEdamamFood()));
    final edamamFoodsWithPantry =
        mergePantryEntryStreams(pantryRepository: pantryRepository, foodStream: maybeEdamamFoods);
    return edamamFoodsWithPantry.map((foods) => removeNull(foods).toBuiltList());
  }

  @override
  Future<BuiltList<EdamamFood>> fetchQuery(String query) => streamQuery(query).first;

  Stream<EdamamFood?> streamFood(EdamamFoodReference? foodReference) {
    if (foodReference == null) return Stream.value(null);

    final edamamEntry = Stream.fromFuture(edamamService.getById(foodReference.id));
    // Multiple edamam foods refer to the same database entry. Replace the generic label with the specific one.
    final edamamFood = edamamEntry.map((e) => e?.toEdamamFood()?.rebuild((b) => b.name = foodReference.name));
    return mergePantryEntryStream(pantryRepository: pantryRepository, foodStream: edamamFood);
  }

  Future<EdamamFood?> fetchFood(EdamamFoodReference? foodReference) => streamFood(foodReference).first;
}
