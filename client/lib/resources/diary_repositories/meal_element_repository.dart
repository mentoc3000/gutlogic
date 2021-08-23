import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/diary_entry/meal_entry.dart';
import '../../models/food/food.dart';
import '../../models/meal_element.dart';
import '../../models/quantity.dart';
import '../../models/serializers.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import '../pantry_service.dart';

class MealElementRepository with FirestoreRepository {
  final PantryService pantryService;

  MealElementRepository({required FirestoreService firestoreService, required this.pantryService}) {
    this.firestoreService = firestoreService;
  }

  static String newMealElementId(MealEntry mealEntry) => '${mealEntry.id}#${DateTime.now().toUtc().toIso8601String()}';

  Stream<MealElement?> stream(MealElement mealElement) {
    final stream = firestoreService.userDiaryCollection.doc(mealElement.mealEntryId).snapshots();
    return stream.map((document) {
      final data = FirestoreService.getDocumentData(document);
      if (data == null) return null;
      final List serializedMealElements = data['mealElements'];
      final serializedMealElement =
          serializedMealElements.firstWhere((i) => (i as Map<String, dynamic>)['id'] == mealElement.id);
      return serializers.deserializeWith(MealElement.serializer, serializedMealElement);
    });
  }

  Future<void> _updateMealEntry(
      MealElement mealElement, Map<String, dynamic> Function(Map<String, dynamic> serializedMealEntry) updater) {
    final mealEntryRef = firestoreService.userDiaryCollection.doc(mealElement.mealEntryId);
    return firestoreService.instance.runTransaction((Transaction tx) async {
      final mealEntrySnapshot = await tx.get(mealEntryRef);
      if (mealEntrySnapshot.exists) {
        final serializedMealEntry = mealEntrySnapshot.data();
        if (serializedMealEntry == null) return null;
        await tx.update(mealEntryRef, updater(serializedMealEntry));
      }
    });
  }

  Future<void> delete(MealElement mealElement) => _updateMealEntry(
        mealElement,
        (serializedMealEntry) {
          (serializedMealEntry['mealElements'] as List)
              .retainWhere((i) => (i as Map<String, dynamic>)['id'] != mealElement.id);
          return serializedMealEntry;
        },
      );

  Future<void> update(MealElement mealElement) => _updateMealEntry(
        mealElement,
        (serializedMealEntry) {
          final mealElementIndex = (serializedMealEntry['mealElements'] as List)
              .indexWhere((i) => (i as Map<String, dynamic>)['id'] == mealElement.id);
          (serializedMealEntry['mealElements'] as List)
              .replaceRange(mealElementIndex, mealElementIndex + 1, [serializers.serialize(mealElement)]);
          return serializedMealEntry;
        },
      );

  Future<void> updateQuantity(MealElement mealElement, Quantity quantity) =>
      update(mealElement.rebuild((b) => b..quantity = quantity.toBuilder()));

  Future<void> updateNotes(MealElement mealElement, String notes) =>
      update(mealElement.rebuild((b) => b..notes = notes));

  Future<MealElement?> addNewMealElementTo(MealEntry mealEntry, {required Food food}) async {
    final mealElementId = newMealElementId(mealEntry);
    final foodReference = food.toFoodReference();
    final mealElement = MealElement(id: mealElementId, foodReference: foodReference);
    return addMealElementTo(mealEntry, mealElement: mealElement);
  }

  Future<MealElement?> addMealElementTo(MealEntry mealEntry, {required MealElement mealElement}) async {
    final updatedEntry = mealEntry
        .rebuild((b) => b..mealElements = mealEntry.mealElements.rebuild((b) => b..add(mealElement)).toBuilder());
    final serialized = serializers.serialize(updatedEntry) as Map<String, dynamic>?;
    if (serialized == null) return null;
    await firestoreService.userDiaryCollection.doc(mealEntry.id).update(serialized);
    return mealElement;
  }
}
