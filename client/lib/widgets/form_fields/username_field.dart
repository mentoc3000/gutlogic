import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/validators.dart';
import '../gl_icons.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final StringValidator? validator;
  final bool enabled;

  const UsernameField({
    Key? key,
    required this.controller,
    this.validator = validate,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(icon: Icon(GLIcons.email), labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: validator,
    );
  }

  static String? validate(String? email) {
    return (email == null || isValidEmail(email)) ? null : 'Invalid email address.';
  }
}
