import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../blocs/login/login.dart';
import '../../routes/routes.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/page_column.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';

class LoginPage extends StatelessWidget {
  static Widget provisioned() {
    return LoginCubit.provider(child: LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Sign In'),
      body: ConstrainedScrollView(builder: (context, constraints) => LoginPageBody()),
    );
  }
}

class LoginPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocListener<LoginCubit, LoginState>(
        listener: ErrorSnackBar.listen,
        child: Column(
          children: [
            AuthSection(onAuthentication: (auth) => context.read<LoginCubit>().login(auth)),
            const Spacer(),
            LoginPageNavigationHelper(),
          ],
        ),
      ),
    );
  }
}

/// Shortcut navigation to the register page.
class LoginPageNavigationHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void navigate() => Navigator.of(context).pushReplacement(Routes.of(context).register);

    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Don\'t have an account? ',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(fontSize: 16, color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = navigate,
          ),
        ],
      ),
    );
  }
}
