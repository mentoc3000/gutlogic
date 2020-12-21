import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/change_password/change_password.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_bloc_delegate.dart';
import '../mocks/mock_firebase_auth.dart';
import '../mocks/mock_user_repository.dart';

void main() {
  group('Change Password Bloc', () {
    final UserRepository userRepository = MockUserRepository();

    final passwordUser = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: [AuthProvider.password].build(),
    );
    final federatedUser = ApplicationUser(
      id: '123',
      email: 'jim@aol.com',
      verified: true,
      consented: true,
      providers: [AuthProvider.apple].build(),
    );
    const currentPassword = '4%,g!y@5)@G>dHxB}FN_';
    const updatedPassword = 'BNk5(!~8/%Tnpr3Hj8JC';
    const mismatchedPassword = 'ihkiPa6]@/jcYi|fp9e"';
    const badPassword = '123';

    when(userRepository.authenticated).thenReturn(true);

    blocTest(
      'initial state is ChangePasswordEntry',
      build: () async {
        when(userRepository.user).thenReturn(passwordUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      skip: 0,
      expect: [ChangePasswordEntry(user: passwordUser, isValid: false, isRepeated: false)],
    );

    blocTest(
      'updates unmatching passwords',
      build: () async {
        when(userRepository.user).thenReturn(passwordUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      act: (bloc) async => bloc.add(ChangePasswordUpdated(
        currentPassword: currentPassword,
        updatedPassword: updatedPassword,
        updatedRepeated: mismatchedPassword,
      )),
      expect: [ChangePasswordEntry(user: passwordUser, isValid: true, isRepeated: false)],
    );

    blocTest(
      'updates matching invalid passwords',
      build: () async {
        when(userRepository.user).thenReturn(passwordUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      act: (bloc) async => bloc.add(ChangePasswordUpdated(
        currentPassword: currentPassword,
        updatedPassword: badPassword,
        updatedRepeated: badPassword,
      )),
      expect: [ChangePasswordEntry(user: passwordUser, isValid: false, isRepeated: true)],
    );

    blocTest(
      'updates matching valid passwords',
      build: () async {
        when(userRepository.user).thenReturn(passwordUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      act: (bloc) async => bloc.add(ChangePasswordUpdated(
        currentPassword: currentPassword,
        updatedPassword: updatedPassword,
        updatedRepeated: updatedPassword,
      )),
      expect: [ChangePasswordEntry(user: passwordUser, isValid: true, isRepeated: true)],
    );

    blocTest(
      'submits password update',
      build: () async {
        mockBlocDelegate();
        when(userRepository.user).thenReturn(passwordUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      act: (bloc) async {
        bloc.add(ChangePasswordSubmitted(
          currentPassword: currentPassword,
          updatedPassword: updatedPassword,
        ));
      },
      expect: [
        ChangePasswordLoading(user: passwordUser),
        ChangePasswordSuccess(user: passwordUser),
      ],
      verify: (bloc) async {
        verify(userRepository.updatePassword(
          currentPassword: currentPassword,
          updatedPassword: updatedPassword,
        )).called(1);
        verify(analyticsService.logPasswordChange()).called(1);
      },
    );

    blocTest(
      'submits password update to federated account',
      build: () async {
        when(userRepository.user).thenReturn(federatedUser);
        return ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        );
      },
      act: (bloc) async {
        bloc.add(ChangePasswordSubmitted(
          currentPassword: currentPassword,
          updatedPassword: updatedPassword,
        ));
      },
      expect: [
        ChangePasswordLoading(user: federatedUser),
        ChangePasswordSuccess(user: federatedUser),
      ],
      verify: (bloc) async {
        verify(userRepository.linkAuthProvider(
          provider: AuthProvider.password,
          credential: captureAnyNamed('credential'),
        )).called(1);
      },
    );
  });
}
