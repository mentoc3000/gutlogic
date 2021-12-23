import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/user_food_details.dart';
import 'package:gutlogic/models/user_food_details_api.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/user_food_details_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import 'user_food_details_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, CrashlyticsService])
void main() {
  group('UserFoodDetailsRepository', () {
    late String userFoodDetailsId;
    late CustomFood food;
    late UserFoodDetailsApi userFoodDetailsApi;
    late UserFoodDetails userFoodDetails;
    late BuiltList<UserFoodDetails> userfooddetailsEntries;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late UserFoodDetailsRepository repository;

    setUp(() async {
      userFoodDetailsId = 'entry1Id';
      food = CustomFood(id: 'foodId', name: 'Corned Beef');
      const sensitivityLevel = SensitivityLevel.moderate;
      const notes = 'easy';
      userFoodDetailsApi = UserFoodDetailsApi(
        id: userFoodDetailsId,
        foodReference: food.toFoodReference(),
        sensitivityLevel: sensitivityLevel,
        notes: notes,
      );
      userFoodDetails = userFoodDetailsApi.toUserFoodDetails();
      userfooddetailsEntries = [userFoodDetailsApi.toUserFoodDetails()].build();
      instance = FakeFirebaseFirestore();
      final userfooddetailsCollection = instance.collection('userfooddetails');
      await userfooddetailsCollection
          .doc(userFoodDetailsId)
          .set(serializers.serializeWith(UserFoodDetailsApi.serializer, userFoodDetailsApi) as Map<String, dynamic>);
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userFoodDetailsCollection).thenReturn(userfooddetailsCollection);
      repository = UserFoodDetailsRepository(firestoreService: firestoreService, crashlytics: crashlyticsService);
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits(userfooddetailsEntries));
    });

    test('streams by food', () async {
      await expectLater(repository.stream(food.toFoodReference()), emits(userFoodDetails));
    });

    test('adds an entry', () async {
      const userFoodDetailsId = 'entry2Id';
      final foodReference = CustomFoodReference(id: 'foodId2', name: 'Cabbage');
      const notes = 'easy';
      final userFoodDetails2 = UserFoodDetails(
        userFoodDetailsId: userFoodDetailsId,
        foodReference: foodReference,
        notes: notes,
      );
      final newUserFoodDetails = await repository.add(userFoodDetails2).first;
      expect(newUserFoodDetails!.foodReference, foodReference);
    });

    test('adds a food', () async {
      final food = CustomFood(id: 'food2', name: 'spinach');
      final newUserFoodDetails = await repository.addFood(food.toFoodReference()).first;
      expect(newUserFoodDetails!.foodReference, food.toFoodReference());
    });

    test('returns existing entry if adding food with existing entry', () async {
      final existingUserFoodDetails = await repository.addFood(food.toFoodReference()).first;
      expect(existingUserFoodDetails!.foodReference.id, food.id);
      expect(existingUserFoodDetails.notes, userFoodDetailsApi.notes);
    });

    test('deletes entry', () async {
      final entriesBeforeDeletion = await instance.collection('userfooddetails').get();
      expect(entriesBeforeDeletion.docs.isEmpty, false);
      await repository.delete(userFoodDetailsApi.toUserFoodDetails());
      final entriesAfterDeletion = await instance.collection('userfooddetails').get();
      expect(entriesAfterDeletion.docs.isEmpty, true);
    });

    test('updates entry', () async {
      const notes = 'new notes';
      final updatedDiaryEntry = userFoodDetailsApi.rebuild((b) => b..notes = notes);
      await repository.updateEntry(updatedDiaryEntry.toUserFoodDetails());
      final retrievedEntry = (await instance.collection('userfooddetails').doc(userFoodDetailsId).get()).data();
      expect(retrievedEntry!['notes'], notes);
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(userFoodDetailsApi.toUserFoodDetails(), notes);
      final retrievedEntry = (await instance.collection('userfooddetails').doc(userFoodDetailsId).get()).data();
      expect(retrievedEntry!['notes'], notes);
    });

    test('removes corrupt entry', () async {
      // Add corrupt userfooddetails entry
      const corruptUserFoodDetailsId = 'entry2Id';
      await instance.collection('userfooddetails').doc(corruptUserFoodDetailsId).set({
        '\$': 'UserFoodDetails',
        'symptom': {
          'symptomType': {
            'name': 'name',
          },
          'severity': 'abc', // severity should be a number
        },
        'datetime': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // returns one good userfooddetails entry
      await expectLater(repository.streamAll(), emits(userfooddetailsEntries));
    });
  });
}
