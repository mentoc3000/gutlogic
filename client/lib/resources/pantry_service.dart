import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:rxdart/rxdart.dart';

import '../models/food_reference/food_reference.dart';
import '../models/pantry/pantry_entry.dart';
import '../models/sensitivity/sensitivity.dart';
import '../models/sensitivity/sensitivity_level.dart';
import '../models/sensitivity/sensitivity_source.dart';
import '../models/user_food_details.dart';
import '../util/null_utils.dart';
import 'searchable_repository.dart';
import 'sensitivity/sensitivity_repository.dart';
import 'user_food_details_repository.dart';

class PantryService implements SearchableRepository<PantryEntry> {
  final SensitivityRepository sensitivityRepository;
  final UserFoodDetailsRepository userFoodDetailsRepository;

  static final initialSensitivity = Sensitivity(level: SensitivityLevel.unknown, source: SensitivitySource.user);

  PantryService({required this.sensitivityRepository, required this.userFoodDetailsRepository});

  Stream<BuiltList<PantryEntry>> streamAll() => userFoodDetailsRepository.streamAll().switchMap(_streamPantryEntries);

  @override
  Stream<BuiltList<PantryEntry>> streamQuery(String query) =>
      userFoodDetailsRepository.streamQuery(query).switchMap(_streamPantryEntries);

  Stream<PantryEntry?> stream(PantryEntry? pantryEntry) =>
      userFoodDetailsRepository.stream(pantryEntry?.foodReference).switchMap(_streamPantryEntry);

  Stream<PantryEntry?> streamByFood(FoodReference? foodReference) =>
      userFoodDetailsRepository.stream(foodReference).switchMap(_streamPantryEntry);

  Future<void> delete(PantryEntry pantryEntry) =>
      userFoodDetailsRepository.deleteByFoodReference(pantryEntry.foodReference);

  Future<void> add(PantryEntry pantryEntry) async {
    final userFoodDetails = UserFoodDetails(
      userFoodDetailsId: pantryEntry.userFoodDetailsId,
      foodReference: pantryEntry.foodReference,
      notes: pantryEntry.notes,
    );
    await userFoodDetailsRepository.add(userFoodDetails);
    await sensitivityRepository.updateLevel(
      pantryEntry.foodReference,
      pantryEntry.sensitivity.level,
    );
  }

  Stream<PantryEntry?> addFood(FoodReference foodReference) {
    return userFoodDetailsRepository.addFood(foodReference).map((userFoodDetails) {
      if (userFoodDetails == null) return null;
      return PantryEntry(
        userFoodDetailsId: userFoodDetails.userFoodDetailsId,
        foodReference: foodReference,
        sensitivity: initialSensitivity,
        notes: userFoodDetails.notes,
      );
    });
  }

  Future<void> updateSensitivityLevel(PantryEntry pantryEntry, SensitivityLevel sensitivityLevel) async {
    await sensitivityRepository.updateLevel(pantryEntry.foodReference, sensitivityLevel);
  }

  Future<void> updateNotes(PantryEntry pantryEntry, String newNotes) async {
    final userFoodDetails = await userFoodDetailsRepository.stream(pantryEntry.foodReference).first;
    if (userFoodDetails == null) return;
    return userFoodDetailsRepository.updateNotes(userFoodDetails, newNotes);
  }

  Stream<BuiltList<PantryEntry>> _streamPantryEntries(BuiltList<UserFoodDetails> userFoodDetails) {
    final pantryEntryStreams = userFoodDetails.map((ufd) => _streamPantryEntry(ufd).whereNotNull());
    return CombineLatestStream(pantryEntryStreams, (Iterable<PantryEntry> entries) => entries.toBuiltList());
  }

  Stream<PantryEntry?> _streamPantryEntry(UserFoodDetails? userFoodDetails) {
    if (userFoodDetails == null) return Stream.value(null);
    final foodSensitivityStream = _streamFoodSensitivity(userFoodDetails.foodReference);
    return foodSensitivityStream.map((sensitivity) => _toPantryEntry(userFoodDetails, sensitivity));
  }

  Stream<Sensitivity> _streamFoodSensitivity(FoodReference foodReference) {
    return sensitivityRepository.stream(foodReference).map((s) => s ?? Sensitivity.unknown);
  }
}

PantryEntry _toPantryEntry(UserFoodDetails userFoodDetails, Sensitivity sensitivity) {
  return PantryEntry(
    userFoodDetailsId: userFoodDetails.userFoodDetailsId,
    foodReference: userFoodDetails.foodReference,
    sensitivity: sensitivity,
    notes: userFoodDetails.notes,
  );
}
