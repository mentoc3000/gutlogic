import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import '../../style/gl_colors.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({Key key, this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlutterPasswordStrength(
        password: password,
        strengthColors: TweenSequence<Color>(
          [
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.red,
                end: Colors.yellow,
              ),
            ),
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.yellow,
                end: Colors.blue,
              ),
            ),
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.blue,
                end: GLColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
