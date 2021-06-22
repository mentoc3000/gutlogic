import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/pantry/pantry_entry_reference.dart';
import 'package:gutlogic/models/sensitivity.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/pantry_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import 'pantry_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, CrashlyticsService])
void main() {
  group('PantryRepository', () {
    late String pantryEntryId;
    late CustomFood food;
    late PantryEntry pantryEntry;
    late BuiltList<PantryEntry> pantryEntries;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late PantryRepository repository;

    setUp(() async {
      pantryEntryId = 'entry1Id';
      food = CustomFood(id: 'foodId', name: 'Corned Beef');
      const sensitivity = Sensitivity.moderate;
      const notes = 'easy';
      pantryEntry = PantryEntry(
        id: pantryEntryId,
        foodReference: food.toFoodReference(),
        sensitivity: sensitivity,
        notes: notes,
      );
      pantryEntries = [pantryEntry].build();
      instance = FakeFirebaseFirestore();
      final pantryCollection = instance.collection('pantry');
      await pantryCollection
          .doc(pantryEntryId)
          .set(serializers.serializeWith(PantryEntry.serializer, pantryEntry) as Map<String, dynamic>);
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userPantryCollection).thenReturn(pantryCollection);
      repository = PantryRepository(firestoreService: firestoreService, crashlytics: crashlyticsService);
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits(pantryEntries));
    });

    test('streams one entry', () async {
      await expectLater(repository.stream(pantryEntry), emits(pantryEntry));
    });

    test('streams by food', () async {
      await expectLater(repository.streamByFood(food.toFoodReference()), emits(pantryEntry));
    });

    test('streams one entry by id', () async {
      await expectLater(repository.streamEntry(pantryEntry.toReference()), emits(pantryEntry));
    });

    test('fetches all entries', () async {
      final entries = await repository.fetchAll();
      expect(entries, pantryEntries);
    });

    test('fetches one entry', () async {
      final entry = await repository.fetchEntry(pantryEntry.toReference());
      expect(entry, pantryEntry);
    });

    test('non-existant id returns null', () async {
      final fakeRef = PantryEntryReference(id: 'fake', sensitivity: Sensitivity.none);
      final entry = await repository.fetchEntry(fakeRef);
      expect(entry, null);
    });

    test('finds a food', () async {
      final foundEntry = await repository.fetchByFood(food.toFoodReference());
      expect(foundEntry, pantryEntry);
    });

    test('adds an entry', () async {
      const pantryEntryId = 'entry2Id';
      final foodReference = CustomFoodReference(id: 'foodId', name: 'Corned Beef');
      const sensitivity = Sensitivity.moderate;
      const notes = 'easy';
      final pantryEntry2 = PantryEntry(
        id: pantryEntryId,
        foodReference: foodReference,
        sensitivity: sensitivity,
        notes: notes,
      );
      final newPantryEntry = await repository.add(pantryEntry2);
      expect(newPantryEntry!.foodReference, foodReference);
    });

    test('adds a food', () async {
      final food = CustomFood(id: 'food2', name: 'spinach');
      final newPantryEntry = await repository.addFood(food.toFoodReference());
      expect(newPantryEntry!.foodReference, food.toFoodReference());
    });

    test('returns existing entry if adding food with existing entry', () async {
      final existingPantryEntry = await repository.addFood(food.toFoodReference());
      expect(existingPantryEntry!.foodReference.id, food.id);
      expect(existingPantryEntry.notes, pantryEntry.notes);
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
      expect(retrievedEntry!['notes'], notes);
    });

    test('updates sensitivity', () async {
      const newSensitivity = Sensitivity.none;
      await repository.updateSensitivity(pantryEntry, newSensitivity);
      final retrievedEntry = (await instance.collection('pantry').doc(pantryEntryId).get()).data();
      expect(retrievedEntry!['sensitivity'], serializers.serializeWith(Sensitivity.serializer, newSensitivity));
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(pantryEntry, notes);
      final retrievedEntry = (await instance.collection('pantry').doc(pantryEntryId).get()).data();
      expect(retrievedEntry!['notes'], notes);
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
