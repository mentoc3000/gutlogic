import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../util/provider.dart';
import '../../util/result.dart';
import '../../util/widget_utils.dart';
import '../../widgets/buttons/gl_flat_button.dart';
import '../../widgets/buttons/stretched_button_content.dart';
import '../auth.dart';
import '../services/auth_apple.dart';
import '../services/auth_google.dart';

class AuthProviderGroup extends StatelessWidget {
  final void Function(Authentication) onAuthentication;

  const AuthProviderGroup({required this.onAuthentication});

  @override
  Widget build(BuildContext context) {
    void onPressed<T extends AuthProviderService>() async {
      await context.read<T>().deauthenticate(); // force a fresh login every time
      maybe(await context.read<T>().authenticate(), onAuthentication);
    }

    final buttons = [
      if (context.has<AppleAuthService>()) AuthProviderAppleButton(onPressed: () => onPressed<AppleAuthService>()),
      if (context.has<GoogleAuthService>()) AuthProviderGoogleButton(onPressed: () => onPressed<GoogleAuthService>()),
    ];

    return Column(children: WidgetUtils.separate(buttons, separator: const Gap(20)));
  }
}

class AuthProviderGoogleButton extends StatelessWidget {
  static final _icon = SvgPicture.asset('assets/auth/google/google_logo.svg');

  final VoidCallback? onPressed;

  const AuthProviderGoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLFlatButton(
      child: StretchedButtonContent(
        label: 'Continue with Google',
        leader: AuthProviderButtonLeader(child: _icon),
      ),
      color: const Color.fromRGBO(66, 133, 244, 1),
      textColor: Colors.white,
      onPressed: () => onPressed?.call(), // never disabled
    );
  }
}

class AuthProviderAppleButton extends StatelessWidget {
  static final _icon = SvgPicture.asset('assets/auth/apple/apple_logo.svg');

  final VoidCallback? onPressed;

  const AuthProviderAppleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLFlatButton(
      child: StretchedButtonContent(
        label: 'Continue with Apple',
        leader: AuthProviderButtonLeader(child: _icon),
      ),
      color: Colors.black,
      textColor: Colors.white,
      onPressed: () => onPressed?.call(), // never disabled
    );
  }
}

class AuthProviderButtonLeader extends StatelessWidget {
  final Widget child;

  const AuthProviderButtonLeader({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(2), child: ClipOval(child: child));
  }
}
