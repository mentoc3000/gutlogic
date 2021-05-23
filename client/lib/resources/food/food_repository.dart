import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food/food.dart';
import '../pantry_repository.dart';
import '../searchable_repository.dart';

abstract class FoodRepository<T extends Food> implements SearchableRepository<T> {
  late final PantryRepository pantryRepository;
}

Stream<T?> mergePantryEntryStream<T extends Food>(
    {required PantryRepository pantryRepository, required Stream<T?> foodStream}) {
  // Cast to T? to accomodate inputs of Stream<T>
  return foodStream.cast<T?>().switchMap((food) async* {
    yield* pantryRepository
        .streamByFood(food?.toFoodReference())
        .map((pantryEntry) => food?.addPantryEntryReference(pantryEntry?.toReference()) as T?);
  });
}

Stream<BuiltList<T?>> mergePantryEntryStreams<T extends Food>(
    {required PantryRepository pantryRepository, required Stream<Iterable<T?>> foodStream}) {
  return foodStream.cast<Iterable<T?>>().switchMap<BuiltList<T?>>((Iterable<T?> foods) {
    if (foods.isEmpty) return Stream.value(<T?>[].build());
    return CombineLatestStream(
        foods.map((f) => mergePantryEntryStream<T>(pantryRepository: pantryRepository, foodStream: Stream.value(f))),
        (Iterable<T?> values) => values.toBuiltList());
  });
}

Iterable<T> removeNull<T>(Iterable<T?> iterable) => iterable.where((element) => element != null).cast<T>();
