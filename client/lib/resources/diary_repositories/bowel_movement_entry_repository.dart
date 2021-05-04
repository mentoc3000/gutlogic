import 'dart:async';

import '../../models/bowel_movement.dart';
import '../../models/diary_entry/bowel_movement_entry.dart';
import '../../models/serializers.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'diary_repository_helpers.dart';

BowelMovementEntry? deserialize(Map<String, dynamic> object) {
  return serializers.deserializeWith(BowelMovementEntry.serializer, object);
}

class BowelMovementEntryRepository
    with FirestoreRepository, DiaryEntryStreamer, DiaryEntryAdder, DiaryEntryDeleter, DiaryEntryUpdater {
  static BowelMovement initialBowelMovementValue = BowelMovement(type: 4, volume: 3);

  BowelMovementEntryRepository({required FirestoreService firestoreService}) {
    this.firestoreService = firestoreService;
  }

  Future<BowelMovementEntry?> create() async {
    final bowelMovementEntry = BowelMovementEntry(
      id: '',
      datetime: DateTime.now().toUtc(),
      bowelMovement: initialBowelMovementValue,
    );
    return add(bowelMovementEntry);
  }

  Future<void> updateType(BowelMovementEntry bowelMovementEntry, int newType) =>
      updateEntry(bowelMovementEntry.rebuild((b) => b..bowelMovement.type = newType));

  Future<void> updateVolume(BowelMovementEntry bowelMovementEntry, int newVolume) =>
      updateEntry(bowelMovementEntry.rebuild((b) => b..bowelMovement.volume = newVolume));
}
