import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../style/gl_colors.dart';

class PasswordStrength extends StatelessWidget {
  final TextEditingController controller;

  const PasswordStrength({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return FlutterPasswordStrength(
          password: value.text,
          strengthColors: const PasswordStrengthColors([Colors.red, Colors.yellow, Colors.blue, GLColors.darkGreen]),
        );
      },
    );
  }
}

class PasswordStrengthColors extends Animatable<Color> {
  final List<Color> colors;

  const PasswordStrengthColors(this.colors);

  @override
  Color transform(double t) => colors[(t * colors.length).clamp(0, colors.length).floor()];
}
