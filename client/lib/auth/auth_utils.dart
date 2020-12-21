import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

final _random = Random();

/// Generate a raw OAuth nonce.
String generateOAuthNonce({int length = 32}) {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  return List<String>.generate(length, (i) => chars[_random.nextInt(chars.length)]).join('');
}

/// Encrypt an OAuth nonce string with SHA256.
String encryptOAuthNonce(String nonce) {
  final ints = utf8.encode(nonce);
  final data = sha256.convert(ints);
  return data.toString();
}
