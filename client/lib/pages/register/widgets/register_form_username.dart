import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/form_fields/focus_history.dart';
import '../../../widgets/form_fields/username_field.dart';

class RegisterFormUsername extends StatelessWidget {
  final TextEditingController controller;

  RegisterFormUsername({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FocusHistory(
      child: Builder(builder: (context) {
        return UsernameField(
          controller: controller,
          validator: (value) => FocusHistory.of(context).blurred ? UsernameField.validate(value) : null,
        );
      }),
    );
  }
}
