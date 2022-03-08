import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/resources/firebase/firestore_service.dart';
import 'package:gutlogic/resources/profile_repository.dart';

void main() {
  group('ProfileRepository', () {
    const path = 'users/testUID';

    test('streams profile', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = ProfileRepository(firestore: FirestoreService(userID: 'testUID', instance: firestore));

      expect(repository.stream.hasValue, false);

      await firestore.doc(path).set({'firstname': 'f', 'lastname': 'l'});
      await Future.delayed(Duration.zero);

      expect(repository.stream.value, Profile(firstname: 'f', lastname: 'l'));

      await firestore.doc(path).set({});
      await Future.delayed(Duration.zero);

      expect(repository.stream.value, Profile(firstname: null, lastname: null));
    });

    test('updates profile', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = ProfileRepository(firestore: FirestoreService(userID: 'testUID', instance: firestore));

      await repository.update(profile: Profile(firstname: 'f', lastname: 'l'));
      expect((await firestore.doc(path).get()).data(), {'firstname': 'f', 'lastname': 'l'});

      await repository.update(profile: Profile(firstname: 'f'));
      expect((await firestore.doc(path).get()).data(), {'firstname': 'f'});

      await repository.update(profile: Profile(lastname: 'l'));
      expect((await firestore.doc(path).get()).data(), {'lastname': 'l'});

      await repository.update(profile: Profile());
      expect((await firestore.doc(path).get()).data(), {});
    });
  });
}
