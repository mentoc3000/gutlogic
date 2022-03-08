import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../blocs/register/register.dart';
import '../../routes/routes.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';

class RegisterPage extends StatelessWidget {
  static Widget provisioned() {
    return RegisterCubit.provider(child: RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Sign Up'),
      body: ConstrainedScrollView(builder: (context, constraints) => RegisterPageBody()),
    );
  }
}

class RegisterPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: ErrorSnackBar.listen,
        child: Column(children: [
          AuthSection(onAuthentication: (auth) => context.read<RegisterCubit>().register(auth)),
          const Spacer(),
          RegisterPageNavigationHelper(),
        ]),
      ),
    );
  }
}

class RegisterPageSkipButton extends StatelessWidget {
  final VoidCallback? onPressed;

  RegisterPageSkipButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Continue without an account'),
      onPressed: onPressed,
    );
  }
}

/// Shortcut navigation to the login page.
class RegisterPageNavigationHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          TextSpan(
            text: 'Sign In',
            style: const TextStyle(fontSize: 16, color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => _navigate(context),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context) {
    Navigator.of(context).pushReplacement(Routes.of(context).login);
  }
}
