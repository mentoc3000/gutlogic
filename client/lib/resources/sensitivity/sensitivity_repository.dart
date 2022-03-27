import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/food_reference/food_reference.dart';
import '../../models/sensitivity/sensitivity.dart';
import '../../models/sensitivity/sensitivity_entry.dart';
import '../../models/sensitivity/sensitivity_level.dart';
import '../../models/serializers.dart';
import '../../models/user_food_details_api.dart';
import '../../util/logger.dart';
import '../firebase/crashlytics_service.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';

class SensitivityRepository with FirestoreRepository {
  final CrashlyticsService crashlytics;
  final BehaviorSubject<BuiltList<SensitivityEntry>> _behaviorSubject = BehaviorSubject();

  Stream<BuiltList<SensitivityEntry>> get _sensitivityEntryStream => _behaviorSubject.stream;

  static const defaultSensitivity = SensitivityLevel.unknown;

  SensitivityRepository({required FirestoreService firestoreService, required this.crashlytics}) {
    this.firestoreService = firestoreService;
    final sensitivityEntryStream = firestoreService.userFoodDetailsCollection.snapshots().map((querySnapshot) =>
        BuiltList<SensitivityEntry>(
            querySnapshot.docs.map(_documentTosensitivityEntry).where((entry) => entry != null)));
    _behaviorSubject.addStream(sensitivityEntryStream);
  }

  Stream<BuiltMap<FoodReference, Sensitivity>> streamAll() {
    return _sensitivityEntryStream.map((ses) => BuiltMap({for (var se in ses) se.foodReference: se.toSensitivity()}));
  }

  Stream<Sensitivity?> stream(FoodReference? foodReference) {
    return foodReference == null
        ? Stream.value(null)
        : _sensitivityEntryStream.map((entries) => findSensitivityEntry(entries, foodReference)?.toSensitivity());
  }

  Future<void> updateLevel(FoodReference foodReference, SensitivityLevel newSensitivityLevel) async {
    final sensitivityEntries = await _sensitivityEntryStream.first;
    final sensitivityEntry = findSensitivityEntry(sensitivityEntries, foodReference);

    if (sensitivityEntry == null) return;

    final userFoodDetailsApiRef = firestoreService.userFoodDetailsCollection.doc(sensitivityEntry.userFoodDetailsId);
    final newSensitivityEntry = sensitivityEntry.rebuild((b) => b.sensitivityLevel = newSensitivityLevel);

    // Use transaction to prevent data overwrite when simultaneously updating
    await firestoreService.instance.runTransaction((Transaction tx) async {
      final sensitivityEntrySnapshot = await tx.get(userFoodDetailsApiRef);
      if (sensitivityEntrySnapshot.exists) {
        final serialized = serializers.serialize(newSensitivityEntry) as Map<String, dynamic>;
        final serializedWithoutId = serialized
          ..remove('userFoodDetailsId')
          ..remove('\$');
        tx.update(userFoodDetailsApiRef, serializedWithoutId);
      }
    });
  }

  SensitivityEntry? _documentTosensitivityEntry(UntypedDocumentSnapshot snapshot) {
    try {
      final serializedData = FirestoreService.getDocumentData(snapshot);
      return serializers.deserializeWith(UserFoodDetailsApi.serializer, serializedData)?.toSensitivityEntry();
    } on DeserializationError catch (error, trace) {
      // If entry is corrupt, log and ignore it
      logger.w(error);
      logger.w(trace);
      unawaited(crashlytics.record(error, trace));
    }
    return null;
  }

  static Sensitivity deserialize(Map<String, dynamic> object) =>
      serializers.deserializeWith(Sensitivity.serializer, object) as Sensitivity;
}

SensitivityEntry? findSensitivityEntry(Iterable<SensitivityEntry> sensitivityEntries, FoodReference foodReference) {
  return sensitivityEntries
      .cast<SensitivityEntry?>()
      .firstWhere((entry) => entry?.foodReference == foodReference, orElse: () => null);
}
