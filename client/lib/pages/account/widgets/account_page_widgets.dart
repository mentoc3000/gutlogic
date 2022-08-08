import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user/application_user.dart';
import '../../../resources/user_repository.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/buttons/gl_flat_button.dart';
import '../../../widgets/info_container.dart';

class AccountPageCreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Create Account'),
      onPressed: () => Navigator.of(context).push(context.read<Routes>().createAccount),
    );
  }
}

class AccountPageLogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Logout'),
      onPressed: () => context.read<UserRepository>().logout(),
    );
  }
}

class AccountPageDeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLFlatButton(
      textColor: GLColors.red,
      onPressed: () => Navigator.of(context).push(Routes.of(context).deleteAccount),
      child: const StretchedButtonContent(label: 'Delete Account'),
    );
  }
}

class AccountDetailsCard extends StatelessWidget {
  final ApplicationUser user;

  const AccountDetailsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return InfoContainer(child: Text('Signed in as ${user.email}', textAlign: TextAlign.center));
  }
}
