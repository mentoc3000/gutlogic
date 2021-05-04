import 'package:flutter/widgets.dart';

import '../../../widgets/form_fields/username_field.dart';

class ResetPasswordEmail extends StatelessWidget {
  final TextEditingController controller;

  ResetPasswordEmail({required this.controller});

  @override
  Widget build(BuildContext context) {
    return UsernameField(controller: controller);
  }
}
