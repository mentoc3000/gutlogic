import 'package:built_collection/built_collection.dart';
import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/blocs/user_cubit.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/resources/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'user_cubit_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  final user = ApplicationUser(
    id: '123',
    email: 'jim@aol.com',
    verified: true,
    consented: true,
    anonymous: false,
    providers: <AuthProvider>[].build(),
  );

  group('User Cubit', () {
    test('emits users', () {
      final repository = MockUserRepository();

      final stream = BehaviorSubject<ApplicationUser?>.seeded(null, sync: true);

      when(repository.user).thenReturn(stream.value);
      when(repository.stream).thenAnswer((_) => stream);

      final cubit = UserCubit(repository: repository);

      expect(cubit.state, null);
      stream.add(user);
      expect(cubit.state, user);
      stream.add(null);
      expect(cubit.state, null);
    });
  });
}
