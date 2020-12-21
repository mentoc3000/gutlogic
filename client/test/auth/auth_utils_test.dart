import 'package:gutlogic/auth/auth_utils.dart';
import 'package:test/test.dart';

void main() {
  test('generateOAuthNonce creates alphanumeric strings', () {
    final nonce = generateOAuthNonce(length: 128);

    expect(nonce.length, 128);

    final alphanumeric = RegExp(r'[0-9A-Za-z]');

    for (var i = 0; i < nonce.length; i++) {
      expect(nonce[i].contains(alphanumeric), true);
    }
  });
}
