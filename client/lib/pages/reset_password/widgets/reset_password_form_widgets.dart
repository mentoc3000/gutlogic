import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/reset_password/reset_password.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/username_field.dart';
import '../models/reset_password_input_group.dart';

class ResetPasswordEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsernameField(input: context.select((ResetPasswordInputGroup group) => group.email));
  }
}

class ResetPasswordSubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Send Reset Link'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final bloc = context.read<ResetPasswordBloc>();
    final form = context.read<ResetPasswordInputGroup>();

    bloc.add(ResetPasswordSubmitted(email: form.email.value));
  }
}
