import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/auth/auth_provider.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_firebase_auth.dart';

void main() {
  group('UserRepository', () {
    MockFirestoreInstance firebaseData;
    MockFirebaseAuth firebaseAuth;
    UserRepository userRepository;

    const mockUID = 'test-uid';
    const mockUsername = 'test@email.com';
    const mockPassword = 'test-password';

    setUp(() {
      firebaseData = MockFirestoreInstance();

      firebaseAuth = MockFirebaseAuth();
      firebaseAuth.createMockFirebaseUser = () {
        final user = MockUser(auth: firebaseAuth);

        when(user.uid).thenReturn(mockUID);
        when(user.email).thenReturn(mockUsername);
        when(user.emailVerified).thenReturn(true);
        when(user.displayName).thenReturn('Mock Display Name');
        when(user.providerData).thenReturn([MockUserInfo(providerId: 'password')]);

        return user;
      };

      userRepository = UserRepository(
        firebaseData: firebaseData,
        firebaseAuth: firebaseAuth,
        authenticator: MockAuthenticator(),
      );
    });

    void expectAuthenticated() {
      expect(userRepository.authenticated, true);
      expect(userRepository.user != null, true);
    }

    void expectUnauthenticated() {
      expect(userRepository.authenticated, false);
      expect(userRepository.user == null, true);
    }

    test('can log in and out', () async {
      expectUnauthenticated();

      await userRepository.login(credential: MockAuthCredential());

      expectAuthenticated();

      await userRepository.logout();

      expectUnauthenticated();
    });

    test('can register', () async {
      await userRepository.register(username: mockUsername, password: mockPassword);

      expectAuthenticated();
    });

    test('cannot login while authenticated', () async {
      await userRepository.login(credential: MockAuthCredential());

      expectAuthenticated();

      expect(userRepository.login(credential: MockAuthCredential()), throwsStateError);
    });

    test('cannot register while authenticated', () async {
      await userRepository.login(credential: MockAuthCredential());

      expectAuthenticated();

      expect(userRepository.register(username: mockUsername, password: mockPassword), throwsStateError);
    });

    test('cannot update user while unauthenticated', () async {
      // All of these methods require the repository to be authenticated.
      expect(userRepository.sendEmailVerification(), throwsStateError);
      expect(userRepository.refreshEmailVerification(), throwsStateError);
      expect(userRepository.updateUsername(username: null), throwsStateError);
      expect(userRepository.updatePassword(currentPassword: null, updatedPassword: null), throwsStateError);
      expect(userRepository.updateMetadata(updatedUser: null), throwsStateError);
      expect(userRepository.reauthenticate(credential: null), throwsStateError);
      expect(userRepository.linkAuthProvider(provider: null, credential: null), throwsStateError);
      expect(userRepository.unlinkAuthProvider(provider: null), throwsStateError);
      expect(userRepository.delete(), throwsStateError);
    });

    test('can update username', () async {
      await userRepository.login(credential: MockAuthCredential());

      expect(userRepository.user.username, mockUsername);

      const updatedUsername = 'test-updated-username';
      await userRepository.updateUsername(username: updatedUsername);

      expect(userRepository.user.username, updatedUsername);
    });

    test('can update password', () async {
      await userRepository.login(credential: MockAuthCredential());

      expect(userRepository.user.username, mockUsername);

      const updatedPassword = 'test-updated-password';
      await userRepository.updatePassword(currentPassword: mockPassword, updatedPassword: updatedPassword);

      expect(userRepository.user.username, mockUsername);
    });

    test('can update metadata', () async {
      await userRepository.login(credential: MockAuthCredential());

      expect(userRepository.user.username, mockUsername);

      const updatedFirstname = 'Updated Firstname';
      const updatedLastname = 'Updated Lastname';

      final updatedUser = userRepository.user.rebuild((b) => b
        ..firstname = updatedFirstname
        ..lastname = updatedLastname);

      await userRepository.updateMetadata(updatedUser: updatedUser);

      expect(userRepository.user.firstname, updatedFirstname);
      expect(userRepository.user.lastname, updatedLastname);
    }, skip: 'blocked by how cloud_firestore_mocks handles snapshots (issue #84)');

    test('cannot link duplicate provider', () async {
      await userRepository.login(credential: MockAuthCredential());
      expect(userRepository.user.providers.contains(AuthProvider.password), true);
      expect(userRepository.linkAuthProvider(provider: AuthProvider.password, credential: MockAuthCredential()),
          throwsException);
    });

    test('cannot unlink missing provider', () async {
      await userRepository.login(credential: MockAuthCredential());
      expect(userRepository.user.providers.contains(AuthProvider.google), false);
      expect(userRepository.unlinkAuthProvider(provider: AuthProvider.google), throwsException);
    });
  });
}
