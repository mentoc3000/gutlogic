import 'dart:async';

import 'package:built_collection/built_collection.dart';

import '../../models/diary_entry/meal_entry.dart';
import '../../models/food/food.dart';
import '../../models/meal_element.dart';
import '../../models/serializers.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'diary_repository_helpers.dart';
import 'meal_element_repository.dart';

MealEntry? deserialize(Map<String, dynamic> object) {
  return serializers.deserializeWith(MealEntry.serializer, object);
}

class MealEntryRepository with FirestoreRepository, TimelineRepository {
  MealElementRepository mealElementRepository;
  MealEntryRepository({required FirestoreService firestoreService, required this.mealElementRepository}) {
    this.firestoreService = firestoreService;
  }

  Future<MealEntry?> create() async {
    final mealEntry = MealEntry(
      id: '',
      datetime: DateTime.now().toUtc(),
      mealElements: BuiltList<MealElement>([]),
    );
    return add(mealEntry);
  }

  Future<MealElement?> createMealElement(MealEntry mealEntry, Food food) =>
      mealElementRepository.addNewMealElementTo(mealEntry, food: food);

  Future<MealElement?> addMealElement(MealEntry mealEntry, MealElement mealElement) async {
    final mealEntryLatest = await getLatest(mealEntry) as MealEntry;
    return mealElementRepository.addMealElementTo(mealEntryLatest, mealElement: mealElement);
  }

  Future<void> reorderMealElement(MealEntry mealEntry, int fromIndex, int toIndex) {
    final mealElementList = mealEntry.mealElements.toList();
    final mealElementToMove = mealElementList.removeAt(fromIndex);
    mealElementList.insert(toIndex, mealElementToMove);
    return updateEntry(mealEntry.rebuild((b) => b..mealElements = mealElementList.build().toBuilder()));
  }

  Future<void> removeMealElement(MealEntry mealEntry, MealElement mealElement) {
    final newMealElementList = mealEntry.mealElements.toList();
    newMealElementList.remove(mealElement);
    return updateEntry(mealEntry.rebuild((b) => b..mealElements = newMealElementList.build().toBuilder()));
  }
}
