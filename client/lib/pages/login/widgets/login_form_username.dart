import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/form_fields/username_field.dart';

class LoginFormUsername extends StatelessWidget {
  final TextEditingController controller;

  LoginFormUsername({required this.controller});

  @override
  Widget build(BuildContext context) {
    return UsernameField(controller: controller, validator: (value) => null);
  }
}
