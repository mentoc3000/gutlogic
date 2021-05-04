import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/login/login.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';
import 'login_form_password.dart';
import 'login_form_username.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _isValidForm = false;

  @override
  void initState() {
    super.initState();
    _usernameTextController.addListener(validateForm);
    _passwordTextController.addListener(validateForm);
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  void validateForm() {
    setState(() {
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
  }

  void onLoginButtonPressed() {
    context.read<LoginBloc>().add(LoginSubmitted(
          username: _usernameTextController.text,
          password: _passwordTextController.text,
        ));
  }

  void onResetPasswordButtonPressed() {
    Navigator.of(context).push(Routes.of(context).resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(listener: listener, builder: builder);
  }

  static void listener(BuildContext context, LoginState state) {
    if (state is LoginError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    }
  }

  Widget builder(BuildContext context, LoginState state) {
    // Disable form buttons while we're waiting on a login attempt, or it already succeeded (prevent double entry).
    final isSubmittable = state is LoginReady;

    final isLoginButtonEnabled = isSubmittable && _isValidForm;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          LoginFormUsername(controller: _usernameTextController),
          LoginFormPassword(controller: _passwordTextController),
          const Spacer(),
          GLPrimaryButton(
            child: const StretchedButtonContent(label: 'Login'),
            onPressed: isLoginButtonEnabled ? onLoginButtonPressed : null,
          ),
          GLTertiaryButton(
            child: const StretchedButtonContent(label: 'I forgot my password'),
            onPressed: isSubmittable ? onResetPasswordButtonPressed : null,
          ),
        ],
      ),
    );
  }
}
