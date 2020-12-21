import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../models/diary_entry/diary_entry.dart';
import '../../util/logger.dart';
import '../firebase/firestore_repository.dart';
import '../firebase/firestore_service.dart';
import 'diary_repository_helpers.dart';

class DiaryRepository with FirestoreRepository, DiaryEntryAdder, DiaryEntryDeleter {
  FirebaseCrashlytics firebaseCrashlytics;
  DiaryRepository({@required FirestoreService firestoreService, this.firebaseCrashlytics}) {
    this.firestoreService = firestoreService;
  }

  Stream<BuiltList<DiaryEntry>> streamAll() {
    final stream = firestoreService.userDiaryCollection.snapshots();
    return stream.map((querySnapshot) => BuiltList<DiaryEntry>(querySnapshot.docs.map<DiaryEntry>((document) {
          try {
            return deserialize(FirestoreService.getDocumentData(document));
          } on DeserializationError catch (error, trace) {
            // If entry is corrupt, log and ignore it
            logger.w(error);
            logger.w(trace);
            unawaited(firebaseCrashlytics?.recordError(error, trace));
          }
          return null;
        }).where((entry) => entry != null)));
  }

  Stream<BuiltList<DiaryEntry>> streamRange(DateTime start, DateTime end) {
    throw UnimplementedError();
  }
}
