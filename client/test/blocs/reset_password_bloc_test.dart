import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/reset_password/reset_password.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks/mock_user_repository.dart';

void main() {
  group('ResetPasswordBloc', () {
    final mockUserRepository = MockUserRepository();

    Future<ResetPasswordBloc> build() async {
      return ResetPasswordBloc(userRepository: mockUserRepository);
    }

    blocTest(
      'initial state is ready',
      build: build,
      skip: 0,
      expect: [
        const ResetPasswordReady(),
      ],
    );

    blocTest(
      'emits success with email',
      build: build,
      act: (bloc) async {
        when(mockUserRepository.resetPassword()).thenAnswer((_) async => {});
        bloc.add(const ResetPasswordSubmitted(email: 'test@test.com'));
      },
      expect: [
        const ResetPasswordLoading(),
        const ResetPasswordSuccess(email: 'test@test.com'),
      ],
    );

    blocTest(
      'emits success with email',
      build: build,
      act: (bloc) async {
        when(mockUserRepository.resetPassword()).thenThrow(MissingUserException());
        bloc.add(const ResetPasswordSubmitted(email: 'test@test.com'));
      },
      expect: [
        const ResetPasswordLoading(),
        const ResetPasswordSuccess(email: 'test@test.com'),
      ],
    );
  });
}
