import 'package:built_collection/built_collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/auth/auth_provider.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_firebase_auth.dart';

void main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore firebaseData;
    late MockFirebaseAuth firebaseAuth;
    late UserRepository userRepository;

    const mockUID = 'test-uid';
    const mockUsername = 'test@email.com';
    const mockPassword = 'test-password';

    setUp(() {
      firebaseData = FakeFirebaseFirestore();

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
        authService: MockAuthService(),
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

      await userRepository.login(
        provider: AuthProvider.password,
        username: mockUsername,
        password: mockPassword,
      );

      expectAuthenticated();

      await userRepository.logout();

      expectUnauthenticated();
    });

    test('can register', () async {
      await userRepository.register(
        username: mockUsername,
        password: mockPassword,
      );

      expectAuthenticated();
    });

    test('cannot login while authenticated', () async {
      await userRepository.login(
        provider: AuthProvider.password,
        username: mockUsername,
        password: mockPassword,
      );

      expectAuthenticated();

      expect(userRepository.login(provider: AuthProvider.password), throwsStateError);
    });

    test('cannot register while authenticated', () async {
      await userRepository.login(
        provider: AuthProvider.password,
        username: mockUsername,
        password: mockPassword,
      );

      expectAuthenticated();

      expect(userRepository.register(username: mockUsername, password: mockPassword), throwsStateError);
    });

    test('cannot update user while unauthenticated', () async {
      const provider = AuthProvider.password;

      final updatedUser = ApplicationUser(
        id: 'id',
        email: 'email@gmail.com',
        verified: true,
        consented: true,
        providers: [provider].build(),
      );

      // All of these methods require the repository to be authenticated.
      expect(userRepository.sendEmailVerification(), throwsStateError);
      expect(userRepository.refreshEmailVerification(), throwsStateError);
      expect(userRepository.updateUsername(username: ''), throwsStateError);
      expect(userRepository.updatePassword(currentPassword: '', updatedPassword: ''), throwsStateError);
      expect(userRepository.updateMetadata(updatedUser: updatedUser), throwsStateError);
      expect(userRepository.reauthenticate(provider: AuthProvider.password), throwsStateError);
      expect(userRepository.linkAuthProvider(provider: provider), throwsStateError);
      expect(userRepository.unlinkAuthProvider(provider: provider), throwsStateError);
      expect(userRepository.delete(), throwsStateError);
    });

    test('can update username', () async {
      await userRepository.login(
        provider: AuthProvider.password,
        username: mockUsername,
        password: mockPassword,
      );

      expect(userRepository.user!.username, mockUsername);

      const updatedUsername = 'test-updated-username';
      await userRepository.updateUsername(username: updatedUsername);

      expect(userRepository.user!.username, updatedUsername);
    });

    test('can update password', () async {
      await userRepository.login(
        provider: AuthProvider.password,
        username: mockUsername,
        password: mockPassword,
      );

      expect(userRepository.user!.username, mockUsername);

      await userRepository.updatePassword(
        currentPassword: mockPassword,
        updatedPassword: 'test-updated-password',
      );

      expect(userRepository.user!.username, mockUsername);
    });

    test('cannot link duplicate provider', () async {
      await userRepository.login(provider: AuthProvider.password);
      expect(userRepository.user!.providers.contains(AuthProvider.password), true);
      expect(userRepository.linkAuthProvider(provider: AuthProvider.password), throwsException);
    });

    test('cannot unlink missing provider', () async {
      await userRepository.login(provider: AuthProvider.password);
      expect(userRepository.user!.providers.contains(AuthProvider.google), false);
      expect(userRepository.unlinkAuthProvider(provider: AuthProvider.google), throwsException);
    });
  });
}
