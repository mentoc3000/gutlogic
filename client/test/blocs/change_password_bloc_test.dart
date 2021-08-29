import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/bloc_helpers.dart';
import 'package:gutlogic/blocs/change_password/change_password.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../flutter_test_config.dart';
import '../mocks/mock_firebase_auth.dart';
import 'change_password_bloc_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('Change Password Bloc', () {
    final userRepository = MockUserRepository();

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

    when(userRepository.authenticated).thenReturn(true);

    test('initial state', () {
      when(userRepository.user).thenReturn(passwordUser);
      expect(
        ChangePasswordBloc(
          userRepository: userRepository,
          authenticator: MockAuthenticator(),
        ).state,
        ChangePasswordEntry(
          user: passwordUser,
          isValid: false,
          isRepeated: false,
        ),
      );
    });

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'submits password update',
      build: () {
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
      expect: () => [
        ChangePasswordLoading(user: passwordUser),
        ChangePasswordSuccess(user: passwordUser),
      ],
      verify: (bloc) {
        verify(userRepository.updatePassword(
          currentPassword: currentPassword,
          updatedPassword: updatedPassword,
        )).called(1);
        verify(analyticsService.logEvent('password_change')).called(1);
      },
    );

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'submits password update to federated account',
      build: () {
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
      expect: () => [
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

    test('errors are recorded', () {
      expect(
          ChangePasswordError(
              message: '',
              user: ApplicationUser(
                  consented: true,
                  email: '',
                  id: '',
                  providers: <AuthProvider>[].build(),
                  verified: true)) is ErrorRecorder,
          true);
    });
  });
}
