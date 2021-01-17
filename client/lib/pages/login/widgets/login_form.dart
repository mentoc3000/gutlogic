import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/login/login.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/email_form_field.dart';
import '../../../widgets/form_fields/password_form_field.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _isValidForm = false;
  final String Function(String) _usernameValidator = EmailValidators.full;
  final String Function(String) _passwordValidator = PasswordValidators.isNotEmpty;

  LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.bloc<LoginBloc>();
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
      // Check if the email and password will be valid after typing is complete
      final isValidUsername = _usernameValidator(_usernameTextController.text) == null;
      final isValidPassword = _passwordValidator(_passwordTextController.text) == null;

      _isValidForm = (_formKey.currentState?.validate() ?? false) && isValidPassword && isValidUsername;
    });
  }

  void onLoginButtonPressed() {
    _bloc.add(LoginSubmitted(
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
    if (state is LoginError) Scaffold.of(context).showSnackBar(buildErrorSnackBar(state.message));
  }

  Widget builder(BuildContext context, LoginState state) {
    // Disable form buttons while we're waiting on a login attempt, or it already succeeded (prevent double entry).
    final isSubmittable = state is LoginReady;

    final isLoginButtonEnabled = isSubmittable &&
        _isValidForm &&
        _usernameTextController.text.isNotEmpty &&
        _passwordTextController.text.isNotEmpty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          EmailFormField(
            controller: _usernameTextController,
            validator: _usernameValidator,
          ),
          PasswordFormField(
            controller: _passwordTextController,
            validator: _passwordValidator,
          ),
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

  static Widget buildErrorSnackBar(String error) => ErrorSnackBar(text: error);
}
