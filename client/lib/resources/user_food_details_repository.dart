import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:rxdart/rxdart.dart';

import '../models/food_reference/food_reference.dart';
import '../models/sensitivity/sensitivity_level.dart';
import '../models/serializers.dart';
import '../models/user_food_details.dart';
import '../models/user_food_details_api.dart';
import '../util/logger.dart';
import '../util/null_utils.dart';
import 'firebase/crashlytics_service.dart';
import 'firebase/firestore_repository.dart';
import 'firebase/firestore_service.dart';
import 'searchable_repository.dart';

class UserFoodDetailsRepository with FirestoreRepository implements SearchableRepository<UserFoodDetails> {
  static const defaultSensitivity = SensitivityLevel.unknown;
  final CrashlyticsService crashlytics;
  final BehaviorSubject<BuiltList<UserFoodDetails>> _behaviorSubject = BehaviorSubject();
  Stream<BuiltList<UserFoodDetails>> get _userFoodDetailsStream => _behaviorSubject.stream;

  UserFoodDetailsRepository({required FirestoreService firestoreService, required this.crashlytics}) {
    this.firestoreService = firestoreService;
    final userFoodDetailsStream = firestoreService.userFoodDetailsCollection.snapshots().map((querySnapshot) =>
        BuiltList<UserFoodDetails>(querySnapshot.docs.map(_documentToUserFoodDetails).whereNotNull()));
    _behaviorSubject.addStream(userFoodDetailsStream);
  }

  Stream<BuiltList<UserFoodDetails>> streamAll() => _userFoodDetailsStream;

  @override
  Stream<BuiltList<UserFoodDetails>> streamQuery(String query) {
    return _userFoodDetailsStream.map((querySnapshot) => BuiltList<UserFoodDetails>(
        querySnapshot.where((entry) => entry.queryText().toLowerCase().contains(query.toLowerCase()))));
  }

  Stream<UserFoodDetails?> stream(FoodReference? foodReference) {
    return foodReference == null
        ? Stream.value(null)
        : streamAll().map((entries) => entries
            .cast<UserFoodDetails?>()
            .firstWhere((entry) => entry?.foodReference == foodReference, orElse: () => null));
  }

  Stream<UserFoodDetails?> _streamdId(String id) {
    return streamAll().map((userFoodDetailsList) => userFoodDetailsList
        .cast<UserFoodDetails?>()
        .firstWhere((element) => element?.userFoodDetailsId == id, orElse: () => null));
  }

  Future<void> delete(UserFoodDetails userFoodDetails) {
    return firestoreService.userFoodDetailsCollection.doc(userFoodDetails.userFoodDetailsId).delete();
  }

  Future<void> deleteByFoodReference(FoodReference foodReference) async {
    final userFoodDetails = await stream(foodReference).first;
    if (userFoodDetails != null) return await delete(userFoodDetails);
  }

  Stream<UserFoodDetails?> add(UserFoodDetails userFoodDetails) async* {
    final serializedNewEntry = serializers.serialize(userFoodDetails) as Map<String, dynamic>;
    serializedNewEntry['\$'] = 'UserFoodDetailsApi';
    serializedNewEntry.remove('userFoodDetailsId');

    final doc = await firestoreService.userFoodDetailsCollection.add(serializedNewEntry);

    // TODO: Clean up this race condition hack
    // Delay for 1 ms to allow added food to propagate to [[_behaviorSubject]]
    // The app works fine without it, but test 'adds a food' reveals a race where the userFoodDetails entry is searched
    // before the change is propagated to the stream, so the latest addition cannot be found.
    await Future.delayed(const Duration(milliseconds: 1));

    yield* _streamdId(doc.id);
  }

  Stream<UserFoodDetails?> addFood(FoodReference foodReference) async* {
    final existingEntry = await stream(foodReference).first;
    if (existingEntry != null) {
      yield* stream(foodReference);
    } else {
      final userFoodDetails = UserFoodDetails(userFoodDetailsId: '', foodReference: foodReference);
      yield* add(userFoodDetails);
    }
  }

  Future<void> updateEntry(UserFoodDetails userFoodDetails) {
    final userFoodDetailsRef = firestoreService.userFoodDetailsCollection.doc(userFoodDetails.userFoodDetailsId);
    // Use transaction to prevent data overwrite when simultaneously updating
    return firestoreService.instance.runTransaction((Transaction tx) async {
      final userFoodDetailsSnapshot = await tx.get(userFoodDetailsRef);
      if (userFoodDetailsSnapshot.exists) {
        final serialized = serializers.serialize(userFoodDetails) as Map<String, dynamic>;
        final serializedWithoutId = serialized
          ..remove('userFoodDetailsId')
          ..remove('\$');
        tx.update(userFoodDetailsRef, serializedWithoutId);
      }
    });
  }

  Future<void> updateNotes(UserFoodDetails userFoodDetails, String newNotes) =>
      updateEntry(userFoodDetails.rebuild((b) => b..notes = newNotes));

  UserFoodDetails? _documentToUserFoodDetails(UntypedDocumentSnapshot snapshot) {
    try {
      final serializedData = FirestoreService.getDocumentData(snapshot);
      return serializers.deserializeWith(UserFoodDetailsApi.serializer, serializedData)?.toUserFoodDetails();
    } on DeserializationError catch (error, trace) {
      // If entry is corrupt, log and ignore it
      logger.w(error);
      logger.w(trace);
      unawaited(crashlytics.record(error, trace));
    }
    return null;
  }

  static UserFoodDetails deserialize(Map<String, dynamic> object) =>
      serializers.deserializeWith(UserFoodDetails.serializer, object) as UserFoodDetails;
}
