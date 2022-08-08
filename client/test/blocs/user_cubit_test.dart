import 'package:firebase_auth/firebase_auth.dart';
import 'package:gutlogic/blocs/user_cubit.dart';
import 'package:gutlogic/models/user/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'user_cubit_test.mocks.dart';

@GenerateMocks([UserRepository, User])
void main() {
  final firebaseUser = MockUser();
  final user = ApplicationUser(
    firebaseUser: firebaseUser,
    consented: true,
  );

  group('User Cubit', () {
    test('emits users', () {
      final repository = MockUserRepository();

      final stream = BehaviorSubject<ApplicationUser?>.seeded(null);

      when(repository.user).thenReturn(stream.value);
      when(repository.stream).thenAnswer((_) => stream);

      final cubit = UserCubit(repository: repository);

      stream.add(user);
      stream.add(null);

      expect(cubit.stream, emitsInOrder([null, user, null]));
    });
  });
}
