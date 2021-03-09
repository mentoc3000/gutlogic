import 'dart:async';
import 'package:pedantic/pedantic.dart';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/food/food.dart';
import '../models/pantry_entry.dart';
import '../models/sensitivity.dart';
import '../models/serializers.dart';
import '../util/logger.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';
import 'searchable_repository.dart';

class PantryRepository with FirestoreRepository implements SearchableRepository<PantryEntry> {
  static const defaultSensitivity = Sensitivity.unknown;
  final FirebaseCrashlytics firebaseCrashlytics;

  PantryRepository({@required FirestoreService firestoreService, this.firebaseCrashlytics}) {
    this.firestoreService = firestoreService;
  }

  Stream<BuiltList<PantryEntry>> streamAll() {
    return firestoreService.userPantryCollection.snapshots().map((querySnapshot) =>
        BuiltList<PantryEntry>(querySnapshot.docs.map(document2pantryEntry).where((entry) => entry != null)));
  }

  @override
  Stream<BuiltList<PantryEntry>> streamQuery(String query) {
    return firestoreService.userPantryCollection.snapshots().map((querySnapshot) => BuiltList<PantryEntry>(querySnapshot
        .docs
        .map(document2pantryEntry)
        .where((entry) => entry.queryText().toLowerCase().contains(query.toLowerCase()))));
  }

  Stream<PantryEntry> stream(PantryEntry pantryEntry) => streamId(pantryEntry.id);

  Stream<PantryEntry> streamId(String pantryEntryId) {
    final stream = firestoreService.userPantryCollection.doc(pantryEntryId).snapshots();
    return stream.map((document) => deserialize(FirestoreService.getDocumentData(document)));
  }

  Future<BuiltList<PantryEntry>> fetchAll() async {
    final snapshot = await firestoreService.userPantryCollection.get();
    return BuiltList<PantryEntry>(snapshot.docs.map(document2pantryEntry).where((entry) => entry != null));
  }

  @override
  Future<BuiltList<PantryEntry>> fetchQuery(String query) async {
    if (query.isEmpty) {
      return BuiltList<PantryEntry>([]);
    }
    final pantryEntries = await fetchAll();
    return pantryEntries.where((entry) => entry.queryText().contains(query)).toBuiltList();
  }

  Future<PantryEntry> fetchId(String id) async {
    final snapshot = await firestoreService.userPantryCollection.doc(id).get();
    return document2pantryEntry(snapshot);
  }

  Future<void> delete(PantryEntry pantryEntry) => deleteById(pantryEntry.id);

  Future<void> deleteById(String pantryEntryId) => firestoreService.userPantryCollection.doc(pantryEntryId).delete();

  Future<PantryEntry> add(PantryEntry pantryEntry) async {
    final id = pantryEntry.id;
    final Map<String, dynamic> serializedNewEntry = serializers.serialize(pantryEntry);
    serializedNewEntry.remove('id');
    serializedNewEntry['\$'] = 'PantryEntry';

    await firestoreService.userPantryCollection.doc(id).set(serializedNewEntry);
    return await fetchId(id);
  }

  Future<PantryEntry> addFood(Food food) {
    final id = food.id;
    final pantryEntry = PantryEntry(id: id, foodReference: food.toFoodReference(), sensitivity: defaultSensitivity);
    return add(pantryEntry);
  }

  Future<void> updateEntry(PantryEntry pantryEntry) {
    final pantryEntryRef = firestoreService.userPantryCollection.doc(pantryEntry.id);
    // Use transaction to prevent data overwrite when simultaneously updating
    return firestoreService.instance.runTransaction((Transaction tx) async {
      final pantryEntrySnapshot = await tx.get(pantryEntryRef);
      if (pantryEntrySnapshot.exists) {
        // TODO: version check the snapshot
        final Map<String, dynamic> serialized = serializers.serialize(pantryEntry);
        final serializedWithoutId = serialized..remove('id');
        await tx.update(pantryEntryRef, serializedWithoutId);
      }
    });
  }

  Future<void> updateSensitivity(PantryEntry pantryEntry, Sensitivity sensitivity) =>
      updateEntry(pantryEntry.rebuild((b) => b..sensitivity = sensitivity));

  Future<void> updateNotes(PantryEntry pantryEntry, String newNotes) =>
      updateEntry(pantryEntry.rebuild((b) => b..notes = newNotes));

  PantryEntry document2pantryEntry(DocumentSnapshot document) {
    try {
      return serializers.deserializeWith(PantryEntry.serializer, FirestoreService.getDocumentData(document));
    } on DeserializationError catch (error, trace) {
      // If entry is corrupt, log and ignore it
      logger.w(error);
      logger.w(trace);
      unawaited(firebaseCrashlytics?.recordError(error, trace));
    }
    return null;
  }

  static PantryEntry deserialize(Map<String, dynamic> object) =>
      serializers.deserializeWith(PantryEntry.serializer, object);
}
