import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/account/account.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../models/account_input_group.dart';
import 'account_delete_dialog.dart';

class AccountFormFirstName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'First Name'),
      controller: context.select((AccountInputGroup group) => group.firstname).controller,
      textCapitalization: TextCapitalization.words,
    );
  }
}

class AccountFormLastName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Last Name'),
      controller: context.select((AccountInputGroup group) => group.lastname).controller,
      textCapitalization: TextCapitalization.words,
    );
  }
}

class AccountFormSaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Save'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    final bloc = context.read<AccountBloc>();
    final form = context.read<AccountInputGroup>();

    bloc.add(AccountUpdate(
      firstname: form.firstname.value,
      lastname: form.lastname.value,
    ));
  }
}

class AccountFormChangePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Change Password'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    Navigator.of(context).push(Routes.of(context).changePassword);
  }
}

class AccountFormLogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLWarningButton(
      child: const StretchedButtonContent(label: 'Logout'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    context.read<AccountBloc>().add(AccountLogOut());
  }
}

class AccountFormDeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLWarningButton(
      child: const StretchedButtonContent(label: 'Delete Account'),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) {
    AccountDeleteDialog.show(context: context);
  }
}
