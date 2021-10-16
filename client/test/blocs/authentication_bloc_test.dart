import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/authentication/authentication.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'authentication_bloc_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('Authentication Bloc', () {
    var userStream = BehaviorSubject<ApplicationUser?>.seeded(null);

    final userRepository = MockUserRepository();

    when(userRepository.stream).thenAnswer((_) => userStream);

    final user = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: <AuthProvider>[].build(),
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits authentication state when stream emits user',
      build: () {
        userStream = BehaviorSubject<ApplicationUser?>.seeded(null);
        return AuthenticationBloc(userRepository: userRepository);
      },
      act: (bloc) {
        userStream.add(null);
        userStream.add(user);
        userStream.add(null);
      },
      expect: () => [
        const Unauthenticated(),
        const Authenticated(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'deauthenticates on log out',
      build: () {
        userStream = BehaviorSubject<ApplicationUser?>.seeded(user);
        return AuthenticationBloc(userRepository: userRepository);
      },
      act: (bloc) {
        bloc.add(const AuthenticationLoggedOut());
        userStream.add(null);
      },
      expect: () => [
        const Authenticated(),
        const Unauthenticated(),
      ],
      verify: (bloc) {
        verify(userRepository.logout()).called(1);
      },
    );
  });
}
