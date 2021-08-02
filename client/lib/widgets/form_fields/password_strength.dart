import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

import '../../style/gl_colors.dart';

class PasswordStrength extends StatelessWidget {
  final String password;

  const PasswordStrength({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterPasswordStrength(
      password: password,
      strengthColors: const PasswordStrengthColors([Colors.red, Colors.yellow, Colors.blue, GLColors.darkGreen]),
    );
  }
}

class PasswordStrengthColors extends Animatable<Color> {
  final List<Color> colors;

  const PasswordStrengthColors(this.colors);

  @override
  Color transform(double t) => colors[(t * colors.length).clamp(0, colors.length).floor()];
}
