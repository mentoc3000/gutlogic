import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/auth_provider.dart';
import '../../../blocs/change_password/change_password.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';
import '../models/change_password_input_group.dart';
import 'change_password_form_widgets.dart';
import 'change_password_upgrade_warning.dart';

class ChangePasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(builder: builder, listener: listener);
  }

  Widget builder(BuildContext context, ChangePasswordState state) {
    final user = context.select((ChangePasswordBloc bloc) => bloc.state.user);
    final hasPasswordProvider = user.providers.contains(AuthProvider.password);

    return BlocProvider(
      create: (context) => ChangePasswordInputGroup(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            hasPasswordProvider ? ChangePasswordFormCurrentPassword() : ChangePasswordUpgradeWarning(email: user.email),
            const SizedBox(height: 20),
            ChangePasswordFormUpdatedPassword(),
            const SizedBox(height: 20),
            ChangePasswordFormSubmitButton(),
          ],
        ),
      ),
    );
  }

  void listener(BuildContext context, ChangePasswordState state) {
    if (state is ChangePasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    } else if (state is ChangePasswordSuccess) {
      Navigator.of(context).pop();
    }
  }
}
