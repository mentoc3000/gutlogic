import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedantic/pedantic.dart';

export 'package:cloud_firestore/cloud_firestore.dart';

/// A type alias for untyped DocumentSnapshot data.
typedef UntypedData = Map<String, dynamic>;

/// A type alias for untyped DocumentSnapshot.
typedef UntypedSnapshot = DocumentSnapshot<UntypedData>;

class FirestoreService {
  final String userID;
  FirebaseFirestore get instance => FirebaseFirestore.instance;
  CollectionReference<UntypedData> get userDiaryCollection => instance.collection('user_data/$userID/diary');
  CollectionReference<UntypedData> get customFoodCollection => instance.collection('user_data/$userID/foods');
  CollectionReference<UntypedData> get userFoodDetailsCollection => instance.collection('user_data/$userID/pantry');

  FirestoreService({required this.userID}) {
    // Web.
    // await FirebaseFirestore.instance.enablePersistence();

    // All other platforms.
    instance.settings = const Settings(persistenceEnabled: true);
  }

  /// Returns the [snapshot] data and adds the document id to the 'id' field
  static UntypedData? getDocumentData(UntypedSnapshot snapshot) {
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
