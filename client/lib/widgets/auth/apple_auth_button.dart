import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../style/gl_colors.dart';
import '../buttons/gl_button.dart';
import 'auth_button_leader.dart';

final _icon = SvgPicture.asset('assets/auth/apple/apple_logo_dark.svg');

class AppleAuthButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// The button action.
  final VoidCallback onPressed;

  AppleAuthButton({Key key, @required this.label, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GLFlatButton(
      label: label,
      leader: AuthButtonLeader(size: GLButton.height, child: _icon),
      onPressed: onPressed,
      color: GLColors.black,
      textColor: GLColors.white,
    );
  }
}
