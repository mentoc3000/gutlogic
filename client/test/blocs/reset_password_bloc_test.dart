import 'package:bloc_test/bloc_test.dart' hide when, verify;
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/reset_password/reset_password.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'reset_password_bloc_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  group('ResetPasswordBloc', () {
    final mockUserRepository = MockUserRepository();

    ResetPasswordBloc build() {
      return ResetPasswordBloc(userRepository: mockUserRepository);
    }

    test('initial state', () {
      expect(build().state, const ResetPasswordReady());
    });

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits success with email',
      build: build,
      act: (bloc) async {
        when(mockUserRepository.resetPassword()).thenAnswer((_) async => {});
        bloc.add(const ResetPasswordSubmitted(email: 'test@test.com'));
      },
      expect: () => [
        const ResetPasswordLoading(),
        const ResetPasswordSuccess(email: 'test@test.com'),
      ],
    );

    blocTest<ResetPasswordBloc, ResetPasswordState>(
      'emits success with email',
      build: build,
      act: (bloc) async {
        when(mockUserRepository.resetPassword()).thenThrow(MissingUserException());
        bloc.add(const ResetPasswordSubmitted(email: 'test@test.com'));
      },
      expect: () => [
        const ResetPasswordLoading(),
        const ResetPasswordSuccess(email: 'test@test.com'),
      ],
    );
  });
}
