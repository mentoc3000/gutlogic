import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/food_reference/food_reference.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:gutlogic/models/user_food_details_api.dart';
import 'package:gutlogic/resources/firebase/crashlytics_service.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../flutter_test_config.dart';
import 'sensitivity_repository_test.mocks.dart';

@GenerateMocks([FirestoreService, CrashlyticsService])
void main() {
  group('SensitivityRepository', () {
    late String sensitivityEntryId;
    late CustomFood food;
    late UserFoodDetailsApi userFoodDetailsApi;
    late Sensitivity sensitivity;
    late BuiltMap<FoodReference, Sensitivity> sensitivityEntries;
    late FakeFirebaseFirestore instance;
    late FirestoreService firestoreService;
    late SensitivityRepository repository;

    setUp(() async {
      sensitivityEntryId = 'entry1Id';
      food = CustomFood(id: 'foodId', name: 'Corned Beef');
      const sensitivityLevel = SensitivityLevel.moderate;
      const notes = 'easy';
      userFoodDetailsApi = UserFoodDetailsApi(
        id: sensitivityEntryId,
        foodReference: food.toFoodReference(),
        sensitivityLevel: sensitivityLevel,
        notes: notes,
      );
      sensitivity = userFoodDetailsApi.toSensitivity();
      sensitivityEntries = BuiltMap<FoodReference, Sensitivity>({food.toFoodReference(): sensitivity});

      instance = FakeFirebaseFirestore();
      final sensitivityCollection = instance.collection('sensitivity');
      await sensitivityCollection
          .doc(sensitivityEntryId)
          .set(serializers.serializeWith(UserFoodDetailsApi.serializer, userFoodDetailsApi) as Map<String, dynamic>);
      firestoreService = MockFirestoreService();
      when(firestoreService.instance).thenReturn(instance);
      when(firestoreService.userFoodDetailsCollection).thenReturn(sensitivityCollection);

      repository = SensitivityRepository(firestoreService: firestoreService, crashlytics: crashlyticsService);
    });

    test('streams all entries', () async {
      await expectLater(repository.streamAll(), emits(sensitivityEntries));
    });

    test('streams by food', () async {
      await expectLater(repository.stream(food.toFoodReference()), emits(sensitivity));
    });

    test('non-existant id returns null', () async {
      final fakeFood = CustomFoodReference(id: '', name: '');
      final entryStream = repository.stream(fakeFood);
      await expectLater(entryStream, emits(null));
    });

    test('finds a food', () async {
      final foundEntryStream = repository.stream(food.toFoodReference());
      await expectLater(foundEntryStream, emits(sensitivity));
    });

    test('updates sensitivity level', () async {
      const newSensitivityLevel = SensitivityLevel.none;
      await repository.updateLevel(food.toFoodReference(), newSensitivityLevel);
      final retrievedEntry = (await instance.collection('sensitivity').doc(sensitivityEntryId).get()).data();
      expect(
          retrievedEntry!['sensitivity'], serializers.serializeWith(SensitivityLevel.serializer, newSensitivityLevel));
    });

    test('removes corrupt entry', () async {
      // Add corrupt sensitivity entry
      const corruptSensitivityEntryId = 'entry2Id';
      await instance.collection('sensitivity').doc(corruptSensitivityEntryId).set({
        '\$': 'SensitivityEntry',
        'symptom': {
          'symptomType': {
            'name': 'name',
          },
          'severity': 'abc', // severity should be a number
        },
        'datetime': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // returns one good sensitivity entry
      await expectLater(repository.streamAll(), emits(sensitivityEntries));
    });
  });
}
