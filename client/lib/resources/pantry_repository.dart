import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

import '../models/food_reference/food_reference.dart';
import '../models/pantry/pantry_entry.dart';
import '../models/sensitivity.dart';
import '../models/serializers.dart';
import '../util/logger.dart';
import 'firebase/crashlytics_service.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';
import 'searchable_repository.dart';

class PantryRepository with FirestoreRepository, SearchableRepository<PantryEntry> {
  static const defaultSensitivity = Sensitivity.unknown;
  final CrashlyticsService crashlytics;
  final BehaviorSubject<BuiltList<PantryEntry>> _behaviorSubject = BehaviorSubject();
  Stream<BuiltList<PantryEntry>> get _pantryStream => _behaviorSubject.stream;

  PantryRepository({required FirestoreService firestoreService, required this.crashlytics}) {
    this.firestoreService = firestoreService;
    final pantryStream = firestoreService.userPantryCollection.snapshots().map((querySnapshot) =>
        BuiltList<PantryEntry>(querySnapshot.docs.map(document2pantryEntry).where((entry) => entry != null)));
    _behaviorSubject.addStream(pantryStream);
  }

  Stream<BuiltList<PantryEntry>> streamAll() => _pantryStream;

  @override
  Stream<BuiltList<PantryEntry>> streamQuery(String query) {
    return _pantryStream.map((querySnapshot) => BuiltList<PantryEntry>(
        querySnapshot.where((entry) => entry.queryText().toLowerCase().contains(query.toLowerCase()))));
  }

  Stream<PantryEntry?> stream(PantryEntry pantryEntry) => streamId(pantryEntry.id);

  Stream<PantryEntry?> streamId(String pantryEntryId) {
    return _pantryStream.map((entries) => entries.cast<PantryEntry?>().firstWhere(
          (entry) => entry?.id == pantryEntryId,
          orElse: () => null,
        ));
  }

  Future<BuiltList<PantryEntry>> fetchAll() => streamAll().first;

  Future<PantryEntry?> fetchId(String id) => streamId(id).first;

  Future<void> delete(PantryEntry pantryEntry) => deleteById(pantryEntry.id);

  Future<void> deleteById(String pantryEntryId) => firestoreService.userPantryCollection.doc(pantryEntryId).delete();

  Future<PantryEntry?> findByFood(FoodReference foodReference) async {
    final pantry = await fetchAll();
    return pantry.cast<PantryEntry?>().firstWhere((entry) => entry?.foodReference == foodReference, orElse: () => null);
  }

  Future<PantryEntry?> add(PantryEntry pantryEntry) async {
    final serializedNewEntry = serializers.serialize(pantryEntry) as Map<String, dynamic>;
    serializedNewEntry.remove('id');
    serializedNewEntry['\$'] = 'PantryEntry';

    final docRef = await firestoreService.userPantryCollection.add(serializedNewEntry);

    // TODO: Clean up this race condition hack
    // Delay for 1 ms to allow added food to propagate to [[_behaviorSubject]]
    // The app works fine without it, but test 'adds a food' reveals a race where the pantry entry is searched
    // before the change is propagated to the stream, so the latest addition cannot be found.
    await Future.delayed(const Duration(milliseconds: 1));

    return await fetchId(docRef.id);
  }

  Future<PantryEntry?> addFood(FoodReference foodReference) async {
    final existingEntry = await findByFood(foodReference);
    if (existingEntry != null) return existingEntry;

    final pantryEntry = PantryEntry(id: '', foodReference: foodReference, sensitivity: defaultSensitivity);
    return await add(pantryEntry);
  }

  Future<void> updateEntry(PantryEntry pantryEntry) {
    final pantryEntryRef = firestoreService.userPantryCollection.doc(pantryEntry.id);
    // Use transaction to prevent data overwrite when simultaneously updating
    return firestoreService.instance.runTransaction((Transaction tx) async {
      final pantryEntrySnapshot = await tx.get(pantryEntryRef);
      if (pantryEntrySnapshot.exists) {
        // TODO: version check the snapshot
        final serialized = serializers.serialize(pantryEntry) as Map<String, dynamic>;
        final serializedWithoutId = serialized..remove('id');
        await tx.update(pantryEntryRef, serializedWithoutId);
      }
    });
  }

  Future<void> updateSensitivity(PantryEntry pantryEntry, Sensitivity sensitivity) =>
      updateEntry(pantryEntry.rebuild((b) => b..sensitivity = sensitivity));

  Future<void> updateNotes(PantryEntry pantryEntry, String newNotes) =>
      updateEntry(pantryEntry.rebuild((b) => b..notes = newNotes));

  PantryEntry? document2pantryEntry(DocumentSnapshot document) {
    try {
      return serializers.deserializeWith(PantryEntry.serializer, FirestoreService.getDocumentData(document));
    } on DeserializationError catch (error, trace) {
      // If entry is corrupt, log and ignore it
      logger.w(error);
      logger.w(trace);
      unawaited(crashlytics.record(error, trace));
    }
    return null;
  }

  static PantryEntry deserialize(Map<String, dynamic> object) =>
      serializers.deserializeWith(PantryEntry.serializer, object) as PantryEntry;
}
