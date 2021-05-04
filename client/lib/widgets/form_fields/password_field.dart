import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/validators.dart';
import '../gl_icons.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final StringValidator? validator;
  final String label;
  final bool enabled;

  PasswordField({
    Key? key,
    this.enabled = true,
    required this.controller,
    this.validator = validate,
    this.label = 'Password',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(icon: const Icon(GLIcons.password), labelText: label),
      obscureText: true, // TODO add option to show password
      autocorrect: false,
      validator: validator,
    );
  }

  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Enter password.';
    }
    if (isPasswordTooShort(password)) {
      return 'Password must be at least 10 characters.';
    }
    if (isPasswordTooLong(password)) {
      return 'Password must be fewer than 64 characters.';
    }
    return null;
  }
}
