import 'package:bloc_test/bloc_test.dart' hide when, verify;
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/account/account.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import 'account_bloc_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('Account Bloc', () {
    final userRepository = MockUserRepository();

    final user = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: <AuthProvider>[].build(),
    );

    when(userRepository.authenticated).thenReturn(true);
    when(userRepository.user).thenReturn(user);

    AccountBloc build() {
      return AccountBloc(userRepository: userRepository);
    }

    test('initial state', () {
      expect(build().state, AccountUpdateReady(user: user));
    });

    // TODO AccountBloc awaits the updated user, but UserRepository is not completely mocked. Revisit after splitting UserRepository from auth service.
    // blocTest<AccountBloc, AccountState>(
    //   'updates account',
    //   build: build,
    //   act: (bloc) {
    //     return bloc.add(AccountUpdate(
    //       firstname: 'update',
    //       lastname: 'update',
    //     ));
    //   },
    //   expect: () => [
    //     AccountUpdateSuccess(
    //       user: user.rebuild((b) => b
    //         ..firstname = 'update'
    //         ..lastname = 'update'),
    //     ),
    //   ],
    //   verify: (bloc) async {
    //     verify(userRepository.updateMetadata).called(1);
    //     verify(analyticsService.logEvent('profile_updated')).called(1);
    //   },
    // );

    blocTest<AccountBloc, AccountState>(
      'logs out',
      build: build,
      act: (bloc) {
        bloc.add(AccountLogOut());
      },
      verify: (bloc) async {
        verify(analyticsService.logEvent('log_out')).called(1);
      },
    );
  });
}
