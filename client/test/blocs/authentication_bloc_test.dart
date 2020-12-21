import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/authentication/authentication.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import '../mocks/mock_user_repository.dart';

void main() {
  group('Authentication Bloc', () {
    final UserRepository userRepository = MockUserRepository();
    final user = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: <AuthProvider>[].build(),
    );

    void stubUserStream(ApplicationUser user) {
      when(userRepository.stream).thenAnswer((_) => BehaviorSubject.seeded(user));
    }

    blocTest(
      'authenticates when UserRepository emits a user',
      build: () async {
        stubUserStream(user);
        return AuthenticationBloc(userRepository: userRepository);
      },
      skip: 0,
      expect: [const AuthenticationUnknown(), const Authenticated()],
    );

    blocTest(
      'authenticates when UserRepository emits a null',
      build: () async {
        stubUserStream(null);
        return AuthenticationBloc(userRepository: userRepository);
      },
      expect: [const Unauthenticated()],
    );
  });
}
