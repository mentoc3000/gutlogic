import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/change_password/change_password.dart';
import '../../../input/input.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/form_fields/password_strength.dart';
import '../models/change_password_input_group.dart';

class ChangePasswordFormCurrentPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PasswordField(
      label: 'Current Password',
      input: context.select((ChangePasswordInputGroup group) => group.currentPassword),
    );
  }
}

class ChangePasswordFormUpdatedPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final input = context.select((ChangePasswordInputGroup group) => group.updatedPassword);

    return Column(
      children: [
        PasswordField(
          label: 'New Password',
          input: input,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
          child: InputValueBuilder<String>(
            input: input,
            builder: (context, value) => PasswordStrength(password: value),
          ),
        )
      ],
    );
  }
}

class ChangePasswordFormSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      enabled: context.select((ChangePasswordInputGroup group) => group.valid),
      child: const StretchedButtonContent(label: 'Save'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final bloc = context.read<ChangePasswordBloc>();
    final form = context.read<ChangePasswordInputGroup>();

    bloc.add(ChangePasswordSubmitted(
      currentPassword: form.currentPassword.value,
      updatedPassword: form.updatedPassword.value,
    ));
  }
}
