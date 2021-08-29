import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/models/food/custom_food.dart';
import 'package:gutlogic/models/food_reference/custom_food_reference.dart';
import 'package:gutlogic/models/user_food_details.dart';
import 'package:gutlogic/models/pantry/pantry_entry.dart';
import 'package:gutlogic/models/sensitivity/sensitivity.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_level.dart';
import 'package:gutlogic/models/sensitivity/sensitivity_source.dart';
import 'package:gutlogic/resources/pantry_service.dart';
import 'package:gutlogic/resources/sensitivity/sensitivity_repository.dart';
import 'package:gutlogic/resources/user_food_details_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'pantry_service_test.mocks.dart';

@GenerateMocks([SensitivityRepository, UserFoodDetailsRepository])
void main() {
  group('pantryService', () {
    late String userFoodDetailsId;
    late CustomFood food;
    late Sensitivity sensitivity;
    late UserFoodDetails userFoodDetails;
    late PantryEntry pantryEntry;
    late BuiltList<PantryEntry> pantryEntries;
    late MockSensitivityRepository sensitivityRepository;
    late MockUserFoodDetailsRepository userFoodDetailsRepository;
    late PantryService repository;

    setUp(() async {
      userFoodDetailsId = 'entry1Id';
      food = CustomFood(id: 'foodId', name: 'Corned Beef');
      final foodReference = food.toFoodReference();
      sensitivity = Sensitivity(level: SensitivityLevel.moderate, source: SensitivitySource.user);
      const notes = 'easy';
      userFoodDetails = UserFoodDetails(
        userFoodDetailsId: userFoodDetailsId,
        foodReference: food.toFoodReference(),
        notes: notes,
      );

      pantryEntry = PantryEntry(
        userFoodDetailsId: userFoodDetailsId,
        foodReference: foodReference,
        sensitivity: sensitivity,
        notes: userFoodDetails.notes,
      );
      pantryEntries = [pantryEntry].toBuiltList();

      sensitivityRepository = MockSensitivityRepository();
      when(sensitivityRepository.stream(any)).thenAnswer((_) => Stream.value(Sensitivity.unknown));
      when(sensitivityRepository.stream(foodReference)).thenAnswer((_) => Stream.value(sensitivity));

      userFoodDetailsRepository = MockUserFoodDetailsRepository();
      when(userFoodDetailsRepository.stream(any)).thenAnswer((_) => Stream.value(null));
      when(userFoodDetailsRepository.stream(foodReference)).thenAnswer((_) => Stream.value(userFoodDetails));
      when(userFoodDetailsRepository.streamAll())
          .thenAnswer((realInvocation) => Stream.value([userFoodDetails].build()));

      repository = PantryService(
        sensitivityRepository: sensitivityRepository,
        userFoodDetailsRepository: userFoodDetailsRepository,
      );
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

    test('non-existant id returns null', () async {
      final foodReference = CustomFoodReference(id: 'food', name: 'butter');
      final fakeRef = PantryEntry(
        userFoodDetailsId: 'fake',
        sensitivity: sensitivity,
        foodReference: foodReference,
        notes: null,
      );
      final entry = await repository.stream(fakeRef).first;
      expect(entry, null);
    });

    test('finds a food', () async {
      final foundEntry = await repository.streamByFood(food.toFoodReference()).first;
      expect(foundEntry, pantryEntry);
    });

    test('adds an entry', () async {
      final foodReference = CustomFoodReference(id: 'foodId', name: 'Corned Beef');
      final pantryEntry2 = PantryEntry(
        userFoodDetailsId: 'entry2Id',
        foodReference: foodReference,
        sensitivity: Sensitivity(
          level: SensitivityLevel.moderate,
          source: SensitivitySource.user,
        ),
        notes: 'easy',
      );
      final userFoodDetails2 = UserFoodDetails(
        userFoodDetailsId: pantryEntry2.userFoodDetailsId,
        foodReference: pantryEntry2.foodReference,
        notes: pantryEntry2.notes,
      );

      when(userFoodDetailsRepository.add(userFoodDetails2)).thenAnswer((_) => Stream.value(userFoodDetails2));
      when(sensitivityRepository.updateLevel(foodReference, any)).thenAnswer((realInvocation) => Future.value(null));

      await repository.add(pantryEntry2);
      verify(userFoodDetailsRepository.add(userFoodDetails2)).called(1);
      verify(sensitivityRepository.updateLevel(pantryEntry2.foodReference, pantryEntry2.sensitivity.level)).called(1);
    });

    test('adds a food', () async {
      final food = CustomFood(id: 'food2', name: 'spinach');
      final newPantryEntry = PantryEntry(
        userFoodDetailsId: 'new',
        foodReference: food.toFoodReference(),
        sensitivity: PantryService.initialSensitivity,
        notes: null,
      );
      final newUserFoodDetails = UserFoodDetails(
        userFoodDetailsId: newPantryEntry.userFoodDetailsId,
        foodReference: newPantryEntry.foodReference,
        notes: newPantryEntry.notes,
      );
      when(userFoodDetailsRepository.addFood(food.toFoodReference()))
          .thenAnswer((_) => Stream.value(newUserFoodDetails));
      final expectedPantryEntry = await repository.addFood(food.toFoodReference()).first;
      expect(expectedPantryEntry, newPantryEntry);
    });

    test('returns existing entry if adding food with existing entry', () async {
      when(userFoodDetailsRepository.addFood(food.toFoodReference()))
          .thenAnswer((realInvocation) => Stream.value(userFoodDetails));
      final existingPantryEntry = await repository.addFood(food.toFoodReference()).first;
      expect(existingPantryEntry!.foodReference.id, food.id);
      expect(existingPantryEntry.notes, userFoodDetails.notes);
    });

    test('deletes entry', () async {
      await repository.delete(pantryEntry);
      verify(userFoodDetailsRepository.deleteByFoodReference(pantryEntry.foodReference)).called(1);
    });

    test('updates sensitivity', () async {
      const newSensitivityLevel = SensitivityLevel.none;
      await repository.updateSensitivityLevel(pantryEntry, newSensitivityLevel);
      verify(sensitivityRepository.updateLevel(pantryEntry.foodReference, newSensitivityLevel)).called(1);
    });

    test('updates notes', () async {
      const notes = 'new notes';
      await repository.updateNotes(pantryEntry, notes);
      verify(userFoodDetailsRepository.updateNotes(userFoodDetails, notes)).called(1);
    });
  });
}
