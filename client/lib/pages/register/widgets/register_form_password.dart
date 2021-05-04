import 'package:flutter/widgets.dart';

import '../../../widgets/form_fields/focus_history.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/form_fields/password_strength.dart';

class RegisterFormPassword extends StatelessWidget {
  final TextEditingController controller;

  RegisterFormPassword({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FocusHistory(
          child: Builder(builder: (context) {
            return PasswordField(
              controller: controller,
              validator: (value) => FocusHistory.of(context).blurred ? PasswordField.validate(value) : null,
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
          child: PasswordStrength(controller: controller),
        ),
      ],
    );
  }
}
