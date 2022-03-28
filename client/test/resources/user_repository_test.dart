import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:test/test.dart';

import '../mocks/mock_firebase_auth.dart';

void main() {
  group('UserRepository', () {
    late UserRepository repository;

    final auth = Authentication(
      method: AuthMethod.email,
      credential: FakeAuthCredential(providerId: 'password'),
    );

    setUp(() {
      final firebaseData = FakeFirebaseFirestore();
      final firebaseAuth = FakeFirebaseAuth();
      repository = UserRepository(firebaseData: firebaseData, firebaseAuth: firebaseAuth);
    });

    test('can login and logout', () async {
      expect(repository.authenticated, false);

      await repository.login(authentication: auth);

      expect(repository.authenticated, true);
      expect(repository.user?.anonymous, false);

      await repository.logout();

      expect(repository.authenticated, false);
    });

    test('can login anonymously', () async {
      await repository.login(authentication: null);

      expect(repository.authenticated, true);
      expect(repository.user?.anonymous, true);
    });

    test('can delete', () async {
      await repository.login(authentication: auth);

      expect(repository.authenticated, true);

      await repository.delete();

      expect(repository.authenticated, false);
    });

    test('cannot login while authenticated', () async {
      await repository.login(authentication: auth);

      expect(repository.authenticated, true);

      expect(repository.login(authentication: auth), throwsStateError);
    });

    test('cannot update user while unauthenticated', () async {
      // All of these services require the repository to be authenticated.
      expect(repository.reauthenticate(authentication: auth), throwsStateError);
      expect(repository.linkAuthProvider(authentication: auth), throwsStateError);
      expect(repository.unlinkAuthProvider(provider: AuthProvider.firebase), throwsStateError);
      expect(repository.delete(), throwsStateError);
    });
  });
}
