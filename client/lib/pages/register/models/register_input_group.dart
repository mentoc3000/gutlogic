import '../../../input/input.dart';
import '../../../util/validators.dart';

class RegisterInputGroup extends InputGroup {
  final InputText username = InputText(validator: validateUsername);
  final InputText password = InputText(validator: validatePassword);

  static String? validateUsername(String value) {
    return isValidEmail(value) ? null : 'Invalid email address.';
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Enter password.';
    }
    if (isPasswordTooShort(value)) {
      return 'Password must be at least 10 characters.';
    }
    if (isPasswordTooLong(value)) {
      return 'Password must be fewer than 64 characters.';
    }
    return null;
  }

  @override
  List<Input> get inputs => [username, password];
}
