import 'package:gutlogic/auth/auth.dart';
import 'package:gutlogic/models/application_user.dart';
import 'package:gutlogic/models/serializers.dart';
import 'package:test/test.dart';

void main() {
  group('ApplicationUser', () {
    test('is deserializable', () {
      final data = {
        'id': '1234',
        'email': 'foo@bar.com',
        'verified': true,
        'providers': ['password', 'google.com'],
      };

      final user = serializers.deserializeWith(ApplicationUser.serializer, data)!;

      expect(user.id, '1234');
      expect(user.email, 'foo@bar.com');
      expect(user.verified, true);
      expect(user.consented, false);
      expect(user.providers.contains(AuthProvider.password), true);
      expect(user.providers.contains(AuthProvider.google), true);
    });
  });
}
