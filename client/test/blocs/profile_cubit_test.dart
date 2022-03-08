import 'package:bloc_test/bloc_test.dart';
import 'package:gutlogic/blocs/profile/profile.dart';
import 'package:gutlogic/resources/profile_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  group('ProfileUpdateCubit', () {
    test('initial state', () {
      final repository = MockProfileRepository();

      when(repository.value).thenReturn(Profile(firstname: 'initial'));

      final cubit = ProfileCubit(repository: repository);

      expect(cubit.state, ProfileInitial(Profile(firstname: 'initial')));
    });

    blocTest<ProfileCubit, ProfileState>(
      'update success',
      build: () {
        final repository = MockProfileRepository();

        when(repository.value).thenReturn(Profile(firstname: 'initial'));
        when(repository.update(profile: anyNamed('profile'))).thenAnswer((_) => Future.value());

        return ProfileCubit(repository: repository);
      },
      act: (bloc) {
        bloc.update(Profile(firstname: 'update'));
      },
      expect: () => [
        ProfileSaving(Profile(firstname: 'update')),
        ProfileSuccess(Profile(firstname: 'update')),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'update failure',
      build: () {
        final repository = MockProfileRepository();

        when(repository.value).thenReturn(Profile(firstname: 'initial'));
        when(repository.update(profile: anyNamed('profile'))).thenThrow(Exception());

        return ProfileCubit(repository: repository);
      },
      act: (bloc) {
        bloc.update(Profile(firstname: 'update'));
      },
      expect: () => [
        ProfileSaving(Profile(firstname: 'update')),
        ProfileFailure(Profile(firstname: 'initial')),
      ],
    );
  });
}
