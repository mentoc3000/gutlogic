import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/login/login.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/form_fields/username_field.dart';
import '../models/login_input_group.dart';

class LoginFormUsername extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsernameField(input: context.select((LoginInputGroup group) => group.username));
  }
}

class LoginFormPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PasswordField(input: context.select((LoginInputGroup group) => group.password));
  }
}

class LoginFormResetPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLTertiaryButton(
      child: const StretchedButtonContent(label: 'I forgot my password'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    Navigator.of(context).push(Routes.of(context).resetPassword);
  }
}

class LoginFormSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Login'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    final form = context.read<LoginInputGroup>();
    bloc.add(LoginSubmitted(
      username: form.username.value,
      password: form.password.value,
    ));
  }
}
