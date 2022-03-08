import 'package:rxdart/rxdart.dart';

import '../models/profile.dart';
import 'firebase/firestore_service.dart';

export 'package:gutlogic/models/profile.dart';

class ProfileRepository {
  late final UntypedDocumentReference _document;

  final BehaviorSubject<Profile> stream = BehaviorSubject();

  Profile get value => stream.valueOrNull ?? Profile();

  ProfileRepository({required FirestoreService firestore}) {
    _document = firestore.userDocument;
    _document.snapshots().map(_deserialize).pipe(stream);
  }

  Profile _deserialize(UntypedDocumentSnapshot snapshot) {
    return Profile.deserialize(snapshot.data() ?? {}) ?? Profile();
  }

  Future<void> update({required Profile profile}) {
    final serialized = Profile.serialize(profile) ?? {};

    serialized['firstname'] ??= FieldValue.delete();
    serialized['lastname'] ??= FieldValue.delete();

    return _document.set(serialized, SetOptions(merge: true));
  }
}
