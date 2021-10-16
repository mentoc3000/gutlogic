import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/profile/profile_bloc.dart';
import 'package:gutlogic/resources/profile_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  group('ProfileUpdateCubit', () {
    test('initial state', () {
      final repository = MockProfileRepository();
      final bloc = ProfileBloc(repository: repository);
      expect(bloc.state, const UpdateInitialState());
    });

    blocTest<ProfileBloc, UpdateState>(
      'update success',
      build: () {
        final repository = MockProfileRepository();
        when(repository.update()).thenAnswer((_) => Future.value());
        return ProfileBloc(repository: repository);
      },
      act: (bloc) {
        bloc.update(profile: Profile());
      },
      expect: () => [
        const UpdateSavingState(),
        const UpdateSuccessState(),
      ],
    );

    blocTest<ProfileBloc, UpdateState>(
      'update failure',
      build: () {
        final repository = MockProfileRepository();
        when(repository.update()).thenThrow(Exception());
        return ProfileBloc(repository: repository);
      },
      act: (bloc) {
        bloc.update(profile: Profile());
      },
      expect: () => [
        const UpdateSavingState(),
        const UpdateSuccessState(),
      ],
    );
  });
}
