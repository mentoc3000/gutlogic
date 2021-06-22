import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/custom_food.dart';
import '../../models/food/food.dart';
import '../../models/food_reference/custom_food_reference.dart';
import '../../models/food_reference/edamam_food_reference.dart';
import '../../models/food_reference/food_reference.dart';
import '../../util/null_utils.dart';
import '../pantry_repository.dart';
import '../searchable_repository.dart';
import 'custom_food_repository.dart';
import 'edamam_food_repository.dart';

class FoodService implements SearchableRepository<Food> {
  final CustomFoodRepository customFoodRepository;
  final EdamamFoodRepository edamamFoodRepository;
  final PantryRepository pantryRepository;

  FoodService({required this.edamamFoodRepository, required this.customFoodRepository, required this.pantryRepository});

  Stream<Food?> streamFood(FoodReference? foodReference) {
    if (foodReference == null) return Stream.value(null);

    if (foodReference is EdamamFoodReference) {
      final edamamFoodStream = edamamFoodRepository.streamFood(foodReference);
      return _mergePantryEntryStream(edamamFoodStream);
    } else if (foodReference is CustomFoodReference) {
      final customFoodStream = customFoodRepository.streamFood(foodReference);
      return _mergePantryEntryStream(customFoodStream);
    } else {
      throw TypeError();
    }
  }

  Future<Food?> fetchFood(FoodReference? foodReference) {
    if (foodReference == null) return Future.value(null);

    if (foodReference is EdamamFoodReference) {
      final edamamFood = edamamFoodRepository.fetchFood(foodReference);
      return _mergePantryEntryFuture(edamamFood);
    } else if (foodReference is CustomFoodReference) {
      final customFood = customFoodRepository.fetchFood(foodReference);
      return _mergePantryEntryFuture(customFood);
    } else {
      throw TypeError();
    }
  }

  @override
  Stream<BuiltList<Food>> streamQuery(String query) {
    if (query.isEmpty) return Stream.value(<CustomFood>[].build());

    final customFoodStream = customFoodRepository.streamQuery(query);
    final edamamFoodStream = edamamFoodRepository.streamQuery(query);

    final customFoodWithPantryRefStream = _mergePantryEntryStreams(customFoodStream);
    final edamamFoodWithPantryRefStream = _mergePantryEntryStreams(edamamFoodStream);

    return CombineLatestStream([customFoodWithPantryRefStream, edamamFoodWithPantryRefStream], _combineFoodLists);
  }

  @override
  Future<BuiltList<Food>> fetchQuery(String query) {
    if (query.isEmpty) return Future.value(<CustomFood>[].build());

    final customFoods = customFoodRepository.fetchQuery(query);
    final edamamFoods = edamamFoodRepository.fetchQuery(query);

    final customFoodsWithPantryRef = _mergePantryEntryFutures(customFoods);
    final edamamFoodsWithPantryRef = _mergePantryEntryFutures(edamamFoods);

    return Future.wait([customFoodsWithPantryRef, edamamFoodsWithPantryRef]).then(_combineFoodLists);
  }

  Future<CustomFood?> add({required String name}) => customFoodRepository.add(name: name);

  Future<void> delete(CustomFood? food) async {
    if (food != null) {
      await customFoodRepository.delete(food);
    }
  }

  Stream<T?> _mergePantryEntryStream<T extends Food>(Stream<T?> foodStream) {
    // Cast to T? to fix runtime type error
    return foodStream.cast<T?>().switchMap<T?>((T? food) {
      return pantryRepository
          .streamByFood(food?.toFoodReference())
          .map<T?>((pantryEntry) => (food?.addPantryEntryReference(pantryEntry?.toReference()) as T?));
    });
  }

  Future<Food?> _mergePantryEntryFuture(Future<Food?> foodFuture) {
    return _mergePantryEntryStream(Stream.fromFuture(foodFuture)).first;
  }

  Stream<Iterable<T>> _mergePantryEntryStreams<T extends Food>(Stream<Iterable<T>> foodStream) {
    // Cast to T? to fix runtime type error
    return foodStream.cast<Iterable<T>>().switchMap<Iterable<T>>((Iterable<T> foods) {
      if (foods.isEmpty) return Stream.value(<T>[].build());
      return CombineLatestStream(
        foods.map((f) => _mergePantryEntryStream(Stream.value(f))),
        (Iterable<T?> values) => values.whereNotNull(),
      );
    });
  }

  Future<Iterable<Food>> _mergePantryEntryFutures(Future<Iterable<Food>> foodFutures) {
    return _mergePantryEntryStreams(Stream.fromFuture(foodFutures)).first;
  }
}

BuiltList<Food> _combineFoodLists(Iterable<Iterable<Food>> values) {
  final customFoods = values.first;
  final edamamFoods = values.last;
  return [...customFoods, ...edamamFoods].toBuiltList();
}
