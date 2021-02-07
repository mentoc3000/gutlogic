import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/account/account.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';
import '../mocks/mock_user_repository.dart';

void main() {
  group('Account Bloc', () {
    final UserRepository userRepository = MockUserRepository();

    final user = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: <AuthProvider>[].build(),
    );

    ApplicationUser updatedUser;

    when(userRepository.authenticated).thenReturn(true);
    when(userRepository.user).thenReturn(user);

    AccountBloc build() {
      return AccountBloc(userRepository: userRepository);
    }

    test('initial state', () {
      expect(build().state, AccountReady(user: user));
    });

    blocTest(
      'updates account',
      build: () {
        mockBlocDelegate();
        return build();
      },
      act: (bloc) async {
        updatedUser = user.rebuild((b) => b.email = 'evan@aol.com');
        return bloc.add(AccountUpdate(user: updatedUser));
      },
      expect: [
        AccountUpdated(),
        AccountReady(user: user),
      ],
      verify: (bloc) async {
        verify(userRepository.updateMetadata(updatedUser: updatedUser)).called(1);
        verify(analyticsService.logEvent('profile_updated')).called(1);
      },
    );

    blocTest(
      'logs out',
      build: () {
        mockBlocDelegate();
        return build();
      },
      act: (bloc) async => bloc.add(AccountLogOut()),
      expect: [
        AccountLoggedOut(),
      ],
      verify: (bloc) async {
        verify(analyticsService.logEvent('log_out')).called(1);
      },
    );
  });
}
