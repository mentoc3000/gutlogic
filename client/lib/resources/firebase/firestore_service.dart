import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedantic/pedantic.dart';

export 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final String userID;
  FirebaseFirestore get instance => FirebaseFirestore.instance;
  CollectionReference get userDiaryCollection => instance.collection('user_data/$userID/diary');
  CollectionReference get customFoodCollection => instance.collection('user_data/$userID/foods');
  CollectionReference get userPantryCollection => instance.collection('user_data/$userID/pantry');

  FirestoreService({required this.userID}) {
    // Web.
    // await FirebaseFirestore.instance.enablePersistence();

    // All other platforms.
    instance.settings = const Settings(persistenceEnabled: true);
  }

  /// Returns the [documentSnapshot] data and adds the document id to the 'id' field
  static Map<String, dynamic>? getDocumentData(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data();

    if (data == null) return null;

    // TODO should we assert data.containsKey('id') == false?

    data['id'] = documentSnapshot.id;

    return data;
  }

  static Timestamp dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

extension Synchronous on CollectionReference {
  DocumentReference addUnawaited(Map<String, dynamic> data) {
    final newDocument = doc();
    unawaited(newDocument.set(data));
    return newDocument;
  }
}
