import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedantic/pedantic.dart';

import './untyped_data.dart';

export 'package:cloud_firestore/cloud_firestore.dart';

export './untyped_data.dart';

/// A type alias for untyped DocumentReference.
typedef UntypedDocumentReference = DocumentReference<UntypedData>;

/// A type alias for untyped DocumentSnapshot.
typedef UntypedDocumentSnapshot = DocumentSnapshot<UntypedData>;

class FirestoreService {
  final String userID;

  late final FirebaseFirestore instance;

  CollectionReference<UntypedData> get userDiaryCollection => instance.collection('user_data/$userID/diary');
  CollectionReference<UntypedData> get customFoodCollection => instance.collection('user_data/$userID/foods');
  CollectionReference<UntypedData> get userFoodDetailsCollection => instance.collection('user_data/$userID/pantry');
  DocumentReference<UntypedData> get userDocument => instance.doc('users/$userID');

  FirestoreService({required this.userID, FirebaseFirestore? instance}) {
    this.instance = instance ?? FirebaseFirestore.instance;
  }

  /// Returns the [snapshot] data and adds the document id to the 'id' field
  static UntypedData? getDocumentData(UntypedDocumentSnapshot snapshot) {
    final data = snapshot.data();

    if (data == null) return null;

    // TODO should we assert data.containsKey('id') == false?

    data['id'] = snapshot.id;

    return data;
  }

  static Timestamp dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

extension Synchronous on CollectionReference<UntypedData> {
  DocumentReference<UntypedData> addUnawaited(UntypedData data) {
    final newDocument = doc();
    unawaited(newDocument.set(data));
    return newDocument;
  }
}
