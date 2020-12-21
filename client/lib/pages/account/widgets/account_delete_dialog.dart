import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../auth/auth.dart';
import '../../../blocs/account_delete/account_delete.dart';
import '../../../resources/user_repository.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/gl_button.dart';
import '../../../widgets/form_fields/password_form_field.dart';
import '../../../widgets/gl_scaffold.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class AccountDeleteDialog extends StatefulWidget {
  /// Show a dialog to confirm the user wants to delete their account. Returns a future which resolves to true if the
  /// user confirmed the account deletion.
  static Future<bool> show({@required BuildContext context}) {
    final repo = context.repository<UserRepository>();
    final user = repo.user;

    assert(user != null); // this dialog makes no sense if we don't have a user

    // Check if the user has a password they can use to reauthenticate.
    final showPasswordEntry = user.providers.contains(AuthProvider.password);

    return showDialog(
      context: context,
      builder: (context) => BlocProvider<AccountDeleteBloc>(
        create: (context) => AccountDeleteBloc(
          userRepository: context.repository<UserRepository>(),
          authenticator: Authenticator.of(context),
        ),
        child: GLScaffold(body: AccountDeleteDialog(showPasswordEntry: showPasswordEntry)),
      ),
      barrierDismissible: false, // require button interaction
    );
  }

  final bool showPasswordEntry;

  AccountDeleteDialog({this.showPasswordEntry});

  @override
  AccountDeleteDialogState createState() => AccountDeleteDialogState(showPasswordEntry: showPasswordEntry);
}

class AccountDeleteDialogState extends State<AccountDeleteDialog> {
  final TextEditingController passwordTextController = TextEditingController();
  final bool showPasswordEntry;

  AccountDeleteDialogState({this.showPasswordEntry});

  @override
  void dispose() {
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountDeleteBloc, AccountDeleteState>(builder: builder, listener: listener);
  }

  void listener(BuildContext context, AccountDeleteState state) {
    if (state is AccountDeleteError) {
      final snackbar = ErrorSnackBar(text: state.message);
      Scaffold.of(context).showSnackBar(snackbar);
    }

    if (state is AccountDeleteDone) {
      Navigator.pushAndRemoveUntil(context, Routes.of(context).login, (_) => false);
    }
  }

  Widget builder(BuildContext context, AccountDeleteState state) {
    final isSubmittable = state is AccountDeleteReady;

    final body = showPasswordEntry ? buildPasswordBody(enabled: isSubmittable) : buildSimpleBody();

    return AlertDialog(
      title: const Text('Delete Account?'),
      content: SingleChildScrollView(child: body),
      actions: [
        GLFlatButton(label: 'Cancel', onPressed: isSubmittable ? onCancelPressed : null),
        GLFlatButton(label: 'Delete', onPressed: isSubmittable ? onDeletePressed : null, textColor: GLColors.red),
      ],
    );
  }

  void onCancelPressed() {
    Navigator.of(context).pop(false);
  }

  void onDeletePressed() {
    final event = showPasswordEntry
        ? AccountDeletePasswordConfirm(password: passwordTextController.text)
        : const AccountDeleteFederatedConfirm();

    context.bloc<AccountDeleteBloc>().add(event);
  }

  /// Build an alert body with a password entry, for users with a password.
  Widget buildPasswordBody({bool enabled}) {
    return ListBody(children: [
      const Text('Are you sure you want to delete your account? Please re-enter your password to continue.'),
      PasswordFormField(controller: passwordTextController, enabled: enabled),
    ]);
  }

  /// Build an alert body without a password entry, for users that only have federated providers.
  Widget buildSimpleBody() {
    return const Text('Are you sure you want to delete your account?');
  }
}
