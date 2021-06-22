import 'package:bloc_test/bloc_test.dart' hide when, verify;
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
    final userRepository = MockUserRepository();

    final user = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: <AuthProvider>[].build(),
    );

    AuthenticationBloc build() {
      return AuthenticationBloc(userRepository: userRepository);
    }

    blocTest<AuthenticationBloc, AuthenticationState>(
      'authenticates when stream emits user',
      build: () {
        when(userRepository.stream).thenAnswer((_) => BehaviorSubject.seeded(user));
        return build();
      },
      expect: () => [
        const Authenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'deauthenticates when stream emits null',
      build: () {
        when(userRepository.stream).thenAnswer((_) => BehaviorSubject.seeded(null));
        return build();
      },
      expect: () => [
        const Unauthenticated(),
      ],
    );
  });
}
