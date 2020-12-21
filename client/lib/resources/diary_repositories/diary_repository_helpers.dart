import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../models/serializers.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'bowel_movement_entry_repository.dart' as bmer;
import 'meal_entry_repository.dart' as mer;
import 'symptom_entry_repository.dart' as ser;

DiaryEntry deserialize(Map<String, dynamic> object) {
  if (object == null) return null;

  switch (object['\$'] as String) {
    case 'MealEntry':
      return mer.deserialize(object);
    case 'BowelMovementEntry':
      return bmer.deserialize(object);
    case 'SymptomEntry':
      return ser.deserialize(object);
  }
  // throw Exception('Unrecognized DiaryEntry type');
  throw TypeError();
}

mixin DiaryEntryStreamer on FirestoreRepository {
  Stream<DiaryEntry> stream(DiaryEntry diaryEntry) => streamById(diaryEntry.id);

  Stream<DiaryEntry> streamById(String diaryEntryId) {
    final stream = firestoreService.userDiaryCollection.doc(diaryEntryId).snapshots();
    return stream.map((document) => deserialize(FirestoreService.getDocumentData(document)));
  }

  Future<DiaryEntry> getLatest(DiaryEntry diaryEntry) => stream(diaryEntry).first;

  Future<DiaryEntry> getLatestById(String diaryEntryId) => streamById(diaryEntryId).first;
}

mixin DiaryEntryAdder on FirestoreRepository {
  /// Add a diary entry to the collection.
  /// Any `id` will be stripped and a new one assigned.
  Future<T> add<T extends DiaryEntry>(T diaryEntry) async {
    final Map<String, dynamic> data = serializers.serialize(diaryEntry);
    data.remove('id');
    final doc = await firestoreService.userDiaryCollection.addUnawaited(data).get();
    return serializers.deserialize(FirestoreService.getDocumentData(doc));
  }
}

mixin DiaryEntryDeleter on FirestoreRepository {
  Future<void> delete(DiaryEntry diaryEntry) => deleteById(diaryEntry.id);

  Future<void> deleteById(String diaryEntryId) => firestoreService.userDiaryCollection.doc(diaryEntryId).delete();
}

mixin DiaryEntryUpdater on FirestoreRepository {
  Future<void> updateEntry(DiaryEntry diaryEntry) {
    final diaryEntryRef = firestoreService.userDiaryCollection.doc(diaryEntry.id);
    // Use transaction to prevent data overwrite when simultaneously updating
    return firestoreService.instance.runTransaction((Transaction tx) async {
      final mealEntrySnapshot = await tx.get(diaryEntryRef);
      if (mealEntrySnapshot.exists) {
        // TODO: version check the snapshot
        final Map<String, dynamic> serialized = serializers.serialize(diaryEntry);
        final serializedWithoutId = serialized..remove('id');
        await tx.update(diaryEntryRef, serializedWithoutId);
      }
    });
  }

  Future<void> updateDateTime(DiaryEntry diaryEntry, DateTime newDateTime) =>
      updateEntry(diaryEntry.rebuild((b) => b..datetime = newDateTime.toUtc()));

  Future<void> updateNotes(DiaryEntry diaryEntry, String newNotes) =>
      updateEntry(diaryEntry.rebuild((b) => b..notes = newNotes));
}
