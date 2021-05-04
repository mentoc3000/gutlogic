import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../buttons/button_helpers.dart';
import '../buttons/buttons.dart';
import '../buttons/gl_flat_button.dart';
import 'auth_button_leader.dart';

final _icon = SvgPicture.asset('assets/auth/google/google_logo.svg');

class GoogleAuthButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// The button action.
  final VoidCallback onPressed;

  GoogleAuthButton({Key? key, required this.label, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = buttonHeight(context);
    return GLFlatButton(
      child: StretchedButtonContent(
        label: label,
        leader: AuthButtonLeader(size: height, child: _icon),
      ),
      onPressed: onPressed,
      color: const Color.fromRGBO(66, 133, 244, 1),
      textColor: Colors.white,
    );
  }
}
