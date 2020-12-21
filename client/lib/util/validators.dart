import 'package:email_validator/email_validator.dart';

typedef StringValidator = String Function(String);

bool isValidUsername(String username) => isValidEmail(username);

bool isValidEmail(String email) => EmailValidator.validate(email);

/// TODO add NIST guidelines such as non-consecutive runs, dictionary words, compromised words
bool isValidPassword(String password) => !isPasswordTooLong(password) && !isPasswordTooShort(password);

bool isPasswordTooShort(String password) => password.length < 10;

bool isPasswordTooLong(String password) => password.length > 64;
