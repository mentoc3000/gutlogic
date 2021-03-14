import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('PantryRepository', () {
    String pantryEntryId;
    PantryEntry pantryEntry;
    BuiltList<PantryEntry> pantryEntries;
    MockFirestoreInstance instance;
    FirestoreService firestoreService;
    PantryRepository repository;

    setUp(() async {
      pantryEntryId = 'entry1Id';
      final food = CustomFoodReference(id: 'foodId', name: 'Corned Beef');
      const sensitivity = Sensitivity.moderate;
      const notes = 'easy';
      pantryEntry = PantryEntry(
        id: pantryEntryId,
        foodReference: food,
        sensitivity: sensitivity,
        notes: notes,
      );
      pantryEntries = [pantryEntry].build();
      instance = MockFirestoreInstance();
      await instance
          .collection('pantry')
          .doc(pantryEntryId)
          .set(serializers.serializeWith(PantryEntry.serializer, pantryEntry));
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userPantryCollection).thenReturn(instance.collection('pantry'));
      repository = PantryRepository(firestoreService: firestoreService);
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits(pantryEntries));
    });

    test('steams one entry', () async {
      await expectLater(repository.stream(pantryEntry), emits(pantryEntry));
    });

    test('steams one entry by id', () async {
      await expectLater(repository.streamId(pantryEntry.id), emits(pantryEntry));
    });

    test('fetches all entries', () async {
      final entries = await repository.fetchAll();
      expect(entries, pantryEntries);
    });

    test('fetches one entry', () async {
      final entry = await repository.fetchId(pantryEntryId);
      expect(entry, pantryEntry);
    });

    test('non-existant id returns null', () async {
      final entry = await repository.fetchId('invalidid');
      expect(entry, null);
    });

    test('adds a food', () async {
      final food = CustomFood(id: 'food2', name: 'spinach');
      final newPantryEntry = await repository.addFood(food);
      expect(newPantryEntry.id, food.id);
      expect(newPantryEntry.foodReference, food.toFoodReference());
    });

    test('deletes entry by id', () async {
      final entriesBeforeDeletion = await instance.collection('pantry').get();
      expect(entriesBeforeDeletion.docs.isEmpty, false);
      await repository.deleteById(pantryEntryId);
      final entriesAfterDeletion = await instance.collection('pantry').get();
      expect(entriesAfterDeletion.docs.isEmpty, true);
    });

    test('deletes entry', () async {
      final entriesBeforeDeletion = await instance.collection('pantry').get();
      expect(entriesBeforeDeletion.docs.isEmpty, false);
      await repository.delete(pantryEntry);
      final entriesAfterDeletion = await instance.collection('pantry').get();
      expect(entriesAfterDeletion.docs.isEmpty, true);
    });

    test('updates entry', () async {
      const notes = 'new notes';
      final updatedDiaryEntry = pantryEntry.rebuild((b) => b..notes = notes);
      await repository.updateEntry(updatedDiaryEntry);
      final retrievedEntry = (await instance.collection('pantry').doc(pantryEntryId).get()).data();
      expect(retrievedEntry['notes'], notes);
    });

    test('updates sensitivity', () async {
      const newSensitivity = Sensitivity.none;
      await repository.updateSensitivity(pantryEntry, newSensitivity);
      final retrievedEntry = (await instance.collection('pantry').doc(pantryEntryId).get()).data();
      expect(retrievedEntry['sensitivity'], serializers.serializeWith(Sensitivity.serializer, newSensitivity));
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(pantryEntry, notes);
      final retrievedEntry = (await instance.collection('pantry').doc(pantryEntryId).get()).data();
      expect(retrievedEntry['notes'], notes);
    });

    test('removes corrupt entry', () async {
      // Add corrupt pantry entry
      const corruptPantryEntryId = 'entry2Id';
      await instance.collection('pantry').doc(corruptPantryEntryId).set({
        '\$': 'PantryEntry',
        'symptom': {
          'symptomType': {
            'name': 'name',
          },
          'severity': 'abc', // severity should be a number
        },
        'datetime': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // returns one good pantry entry
      await expectLater(repository.streamAll(), emits(pantryEntries));
    });
  });
}
