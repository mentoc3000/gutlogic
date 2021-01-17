import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/apple/apple_auth.dart';
import '../../../blocs/landing/landing.dart';
import '../../../routes/routes.dart';
import '../../../widgets/auth/apple_auth_button.dart';
import '../../../widgets/auth/google_auth_button.dart';
import '../../../widgets/buttons/buttons.dart';

class LandingPageButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingBloc, LandingState>(builder: builder);
  }

  Widget builder(BuildContext context, LandingState state) {
    return Column(
      children: [
        GoogleAuthButton(
          label: 'Continue with Google',
          onPressed: () {
            if (state is LandingReady) onGoogleButtonPressed(context);
          },
        ),
        if (AppleAuth.available)
          AppleAuthButton(
            label: 'Continue with Apple',
            onPressed: () {
              if (state is LandingReady) onAppleButtonPressed(context);
            },
          ),
        GLPrimaryButton(
          child: const StretchedButtonContent(label: 'Log in with your email'),
          onPressed: state is LandingReady ? () => onLoginButtonPressed(context) : null,
        ),
        const SizedBox(height: 20),
        GLTertiaryButton(
          child: const StretchedButtonContent(label: 'Create a new account'),
          onPressed: state is LandingReady ? () => onRegisterButtonPressed(context) : null,
        ),
      ],
    );
  }

  void onGoogleButtonPressed(BuildContext context) {
    context.bloc<LandingBloc>().add(const LandingContinueGoogle());
  }

  void onAppleButtonPressed(BuildContext context) {
    context.bloc<LandingBloc>().add(const LandingContinueApple());
  }

  void onLoginButtonPressed(BuildContext context) {
    Navigator.of(context).push(Routes.of(context).login);
  }

  void onRegisterButtonPressed(BuildContext context) {
    Navigator.of(context).push(Routes.of(context).register);
  }
}
