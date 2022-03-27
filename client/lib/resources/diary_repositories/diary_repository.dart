import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../util/logger.dart';
import '../firebase/crashlytics_service.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'diary_repository_helpers.dart';

class DiaryRepository with FirestoreRepository, TimelineRepository {
  final CrashlyticsService crashlytics;
  DiaryRepository({required FirestoreService firestoreService, required this.crashlytics}) {
    this.firestoreService = firestoreService;
  }

  Stream<BuiltList<DiaryEntry>> streamAll() {
    final stream = firestoreService.userDiaryCollection.snapshots();
    return stream.map((querySnapshot) =>
        BuiltList<DiaryEntry>(querySnapshot.docs.map(documentToDiaryEntry).where((entry) => entry != null)));
  }

  Future<BuiltList<DiaryEntry>> getAll() async {
    final snapshot = await firestoreService.userDiaryCollection.get();
    return BuiltList<DiaryEntry>(snapshot.docs.map(documentToDiaryEntry).where((entry) => entry != null));
  }

  Stream<BuiltList<DiaryEntry>> streamRange(DateTime start, DateTime end) {
    throw UnimplementedError();
  }

  DiaryEntry? documentToDiaryEntry(DocumentSnapshot<UntypedData> document) {
    try {
      return deserialize(FirestoreService.getDocumentData(document));
    } on DeserializationError catch (error, trace) {
      // If entry is corrupt, log and ignore it
      logger.w(error);
      logger.w(trace);
      unawaited(crashlytics.record(error, trace));
    }
    return null;
  }
}
