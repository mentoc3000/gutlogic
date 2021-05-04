import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/form_fields/password_field.dart';

class LoginFormPassword extends StatelessWidget {
  final TextEditingController controller;

  LoginFormPassword({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PasswordField(controller: controller, validator: (value) => null);
  }
}
