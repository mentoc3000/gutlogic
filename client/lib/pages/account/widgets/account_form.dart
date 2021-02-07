import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../../blocs/account/account.dart';
import '../../../models/application_user.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/gl_text_form_field.dart';
import '../../../widgets/snack_bars/info_snack_bar.dart';
import '../../error_page.dart';
import '../../loading_page.dart';
import 'account_delete_dialog.dart';
import 'delete_account_button.dart';

class AccountForm extends StatefulWidget {
  @override
  AccountFormState createState() => AccountFormState();
}

class AccountFormState extends State<AccountForm> {
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateTextControllerValues();
  }

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(listener: listener, builder: builder);
  }

  void listener(BuildContext context, AccountState state) {
    updateTextControllerValues();
    if (state is AccountUpdated) {
      // TODO: upon saving, remove focus on text fields
      final snackbar = InfoSnackBar(text: 'Account updated');
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  void updateTextControllerValues() {
    final state = context.read<AccountBloc>().state;

    if (state is AccountReady) {
      firstNameTextController.text = state.user.firstname;
      lastNameTextController.text = state.user.lastname;
    }
  }

  Widget builder(BuildContext context, AccountState state) {
    if (state is AccountLoading) {
      return buildAccountLoadingBody(context, state);
    }

    if (state is AccountError) {
      return buildAccountErrorBody(context, state);
    }

    final isFormEnabled = state is AccountReady;

    final user = state is AccountReady ? state.user : null;

    return ListView(
      children: [
        const SizedBox(height: 20),
        buildAccountFormField(label: 'First Name', controller: firstNameTextController, enabled: isFormEnabled),
        const SizedBox(height: 20),
        buildAccountFormField(label: 'Last Name', controller: lastNameTextController, enabled: isFormEnabled),
        const SizedBox(height: 20),
        buildChangePasswordButton(onPressed: onChangePasswordPressed),
        const SizedBox(height: 20),
        buildSaveButton(onPressed: isFormEnabled ? () => onSavePressed(user) : null),
        const SizedBox(height: 20),
        buildLogoutButton(onPressed: isFormEnabled ? onLogOutPressed : null),
        const SizedBox(height: 20),
        buildDeleteButton(onPressed: isFormEnabled ? onDeletePressed : null),
      ],
    );
  }

  void onSavePressed(ApplicationUser user) {
    final updatedUser = user.rebuild((b) => b
      ..firstname = firstNameTextController.text
      ..lastname = lastNameTextController.text);

    context.read<AccountBloc>().add(AccountUpdate(user: updatedUser));
  }

  void onChangePasswordPressed() {
    Navigator.of(context).push(Routes.of(context).changePassword);
  }

  void onLogOutPressed() {
    context.read<AccountBloc>().add(AccountLogOut());
  }

  void onDeletePressed() async {
    unawaited(AccountDeleteDialog.show(context: context));
  }

  static Widget buildAccountErrorBody(BuildContext context, AccountError state) {
    return ErrorPage(message: state.message);
  }

  static Widget buildAccountLoadingBody(BuildContext context, AccountLoading state) {
    return LoadingPage();
  }

  static GLTextFormField buildAccountFormField({String label, TextEditingController controller, bool enabled}) {
    return GLTextFormField(
      controller: controller,
      enabled: enabled,
      labelText: label,
    );
  }

  static Widget buildChangePasswordButton({VoidCallback onPressed}) {
    return GLSecondaryButton(
      child: const StretchedButtonContent(label: 'Change Password'),
      onPressed: onPressed,
    );
  }

  static Widget buildSaveButton({VoidCallback onPressed}) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Save'),
      onPressed: onPressed,
    );
  }

  static Widget buildLogoutButton({VoidCallback onPressed}) {
    return GLWarningButton(
      child: const StretchedButtonContent(label: 'Logout'),
      onPressed: onPressed,
    );
  }

  static Widget buildDeleteButton({VoidCallback onPressed}) {
    // TODO: differentiate this style from logout
    return DeleteAccountButton(
      child: const StretchedButtonContent(label: 'Delete Account'),
      onPressed: onPressed,
    );
  }
}
