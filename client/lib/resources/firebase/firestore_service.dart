import 'package:pedantic/pedantic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final String userId;
  FirebaseFirestore get instance => FirebaseFirestore.instance;
  CollectionReference get userDiaryCollection => instance.collection('user_data/$userId/diary');
  CollectionReference get customFoodCollection => instance.collection('user_data/$userId/foods');

  FirestoreService({this.userId}) {
    // Web.
    // await FirebaseFirestore.instance.enablePersistence();

    // All other platforms.
    instance.settings = const Settings(persistenceEnabled: true);
  }

  /// Returns the [documentSnapshot] data and adds the document id to the 'id' field
  static Map<String, dynamic> getDocumentData(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data();

    if (data == null) return null;

    data['id'] = documentSnapshot.id;
    return data;
  }

  static Timestamp dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

extension Synchronous on CollectionReference {
  DocumentReference addUnawaited(Map<String, dynamic> data) {
    assert(data != null);
    final newDocument = doc();
    unawaited(newDocument.set(data));
    return newDocument;
  }
}
