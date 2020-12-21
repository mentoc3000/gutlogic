import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';

import '../../../blocs/account/account.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/gl_button.dart';
import '../../../widgets/form_fields/gl_text_form_field.dart';
import '../../../widgets/snack_bars/info_snack_bar.dart';
import '../../error_page.dart';
import '../../loading_page.dart';
import 'account_delete_dialog.dart';

class AccountForm extends StatefulWidget {
  @override
  AccountFormState createState() => AccountFormState();
}

class AccountFormState extends State<AccountForm> {
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();

  AccountBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.bloc<AccountBloc>();
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
      // TODO: use GLSnackBar
      final snackbar = InfoSnackBar(text: 'Account updated');
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  void updateTextControllerValues() {
    if (bloc.state is AccountReady) {
      final user = (bloc.state as AccountReady).user;
      firstNameTextController.text = user.firstname;
      lastNameTextController.text = user.lastname;
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

    return ListView(
      children: [
        const SizedBox(height: 20),
        buildAccountFormField(label: 'First Name', controller: firstNameTextController, enabled: isFormEnabled),
        const SizedBox(height: 20),
        buildAccountFormField(label: 'Last Name', controller: lastNameTextController, enabled: isFormEnabled),
        const SizedBox(height: 20),
        buildChangePasswordButton(onPressed: onChangePasswordPressed),
        const SizedBox(height: 20),
        buildSaveButton(onPressed: isFormEnabled ? onSavePressed : null),
        const SizedBox(height: 20),
        buildLogoutButton(onPressed: isFormEnabled ? onLogOutPressed : null),
        const SizedBox(height: 20),
        buildDeleteButton(onPressed: isFormEnabled ? onDeletePressed : null),
      ],
    );
  }

  void onSavePressed() {
    final currentUser = (bloc.state as AccountReady).user;
    final updatedUser = currentUser.rebuild((b) => b
      ..firstname = firstNameTextController.text
      ..lastname = lastNameTextController.text);

    bloc.add(AccountUpdate(user: updatedUser));
  }

  void onChangePasswordPressed() {
    Navigator.of(context).push(Routes.of(context).changePassword);
  }

  void onLogOutPressed() {
    bloc.add(AccountLogOut());
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
    return GLSecondaryRaisedButton(
      label: 'Change Password',
      onPressed: onPressed,
    );
  }

  static Widget buildSaveButton({VoidCallback onPressed}) {
    return GLPrimaryRaisedButton(
      label: 'Save',
      onPressed: onPressed,
    );
  }

  static Widget buildLogoutButton({VoidCallback onPressed}) {
    return GLWarningRaisedButton(
      label: 'Logout',
      onPressed: onPressed,
    );
  }

  static Widget buildDeleteButton({VoidCallback onPressed}) {
    return GLFlatButton(
      label: 'Delete Account',
      textColor: GLColors.red,
      onPressed: onPressed,
    );
  }
}
