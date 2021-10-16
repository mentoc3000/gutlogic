import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/authentication/authentication.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/buttons/gl_flat_button.dart';
import 'account_delete_dialog.dart';

class AccountPageChangePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Change Password'),
      onPressed: () => Navigator.of(context).push(Routes.of(context).changePassword),
    );
  }
}

class AccountPageLogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Logout'),
      onPressed: () => context.read<AuthenticationBloc>().add(const AuthenticationLoggedOut()),
    );
  }
}

class AccountPageDeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLFlatButton(
      child: const StretchedButtonContent(label: 'Delete Account'),
      textColor: GLColors.red,
      onPressed: () => AccountDeleteDialog.show(context: context),
    );
  }
}
