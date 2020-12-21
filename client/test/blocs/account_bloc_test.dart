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

    blocTest(
      'initial state is AccountReady(user: user)',
      build: () async => AccountBloc(userRepository: userRepository),
      skip: 0,
      expect: [AccountReady(user: user)],
    );

    blocTest(
      'updates account',
      build: () async {
        mockBlocDelegate();
        return AccountBloc(userRepository: userRepository);
      },
      act: (bloc) async {
        updatedUser = user.rebuild((b) => b.email = 'evan@aol.com');
        return bloc.add(AccountUpdate(user: updatedUser));
      },
      expect: [AccountUpdated(), AccountReady(user: user)],
      verify: (bloc) async {
        verify(userRepository.updateMetadata(updatedUser: updatedUser)).called(1);
        verify(analyticsService.logUpdateProfile()).called(1);
      },
    );

    blocTest(
      'logs out',
      build: () async {
        mockBlocDelegate();
        return AccountBloc(userRepository: userRepository);
      },
      act: (bloc) async => bloc.add(AccountLogOut()),
      expect: [AccountLoggedOut()],
      verify: (bloc) async {
        verify(analyticsService.logLogOut()).called(1);
      },
    );
  });
}
