import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/register/register.dart';
import '../../../input/input.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/form_fields/password_strength.dart';
import '../../../widgets/form_fields/username_field.dart';
import '../models/register_input_group.dart';

class RegisterFormUsername extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsernameField(input: context.select((RegisterInputGroup group) => group.username));
  }
}

class RegisterFormPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final input = context.select((RegisterInputGroup group) => group.password);

    return Column(
      children: [
        PasswordField(input: input),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
          child: InputValueBuilder<String>(
            input: input,
            builder: (context, value) => PasswordStrength(password: value),
          ),
        ),
      ],
    );
  }
}

class RegisterFormSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      enabled: context.select((RegisterInputGroup group) => group.valid),
      child: const StretchedButtonContent(label: 'Register'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final bloc = context.read<RegisterBloc>();
    final form = context.read<RegisterInputGroup>();

    bloc.add(RegisterSubmitted(
      username: form.username.value,
      password: form.password.value,
    ));
  }
}
