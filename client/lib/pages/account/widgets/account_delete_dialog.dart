import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/auth.dart';
import '../../../blocs/account_delete/account_delete.dart';
import '../../../input/input.dart';
import '../../../resources/user_repository.dart';
import '../../../routes/routes.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/gl_scaffold.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class AccountDeleteDialog extends StatefulWidget {
  /// Show a dialog to confirm the user wants to delete their account.
  ///
  /// Returns a future which resolves to true if the user confirmed the account deletion.
  static Future<bool?> show({required BuildContext context}) {
    final user = context.read<UserRepository>().user;

    assert(user != null); // this dialog makes no sense if we don't have a user

    // Check if the user has a password they can use to reauthenticate.
    final showPasswordEntry = user!.providers.contains(AuthProvider.password);

    return showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider<AccountDeleteBloc>(
        create: (context) => AccountDeleteBloc(
          userRepository: context.read<UserRepository>(),
          authenticator: Authenticator.of(context),
        ),
        child: GLScaffold(body: AccountDeleteDialog(requirePassword: showPasswordEntry)),
      ),
      barrierDismissible: false, // require button interaction
    );
  }

  final bool requirePassword;

  AccountDeleteDialog({required this.requirePassword});

  @override
  AccountDeleteDialogState createState() => AccountDeleteDialogState(requirePassword: requirePassword);
}

class AccountDeleteDialogState extends State<AccountDeleteDialog> {
  final InputText password = InputText();

  final bool requirePassword;

  AccountDeleteDialogState({required this.requirePassword});

  @override
  void dispose() {
    password.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountDeleteBloc, AccountDeleteState>(builder: builder, listener: listener);
  }

  void listener(BuildContext context, AccountDeleteState state) {
    if (state is AccountDeleteError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    } else if (state is AccountDeleteDone) {
      Navigator.pushAndRemoveUntil(context, Routes.of(context).login, (_) => false);
    }
  }

  Widget builder(BuildContext context, AccountDeleteState state) {
    final isSubmittable = state is AccountDeleteReady;

    return AlertDialog(
      title: const Text('Delete Account?'),
      content: SingleChildScrollView(
        child: requirePassword ? AccountDeletePasswordWarning(field: password) : AccountDeleteSimpleWarning(),
      ),
      actions: [
        GLTertiaryButton(
          enabled: state is AccountDeleteReady,
          child: const ShrinkWrappedButtonContent(label: 'Cancel'),
          onPressed: isSubmittable ? onCancelPressed : null,
        ),
        GLWarningButton(
          enabled: state is AccountDeleteReady,
          child: const ShrinkWrappedButtonContent(label: 'Delete'),
          onPressed: isSubmittable ? onDeletePressed : null,
        ),
      ],
    );
  }

  void onCancelPressed() {
    Navigator.of(context).pop(false);
  }

  void onDeletePressed() {
    final event = requirePassword
        ? AccountDeletePasswordConfirm(password: password.value)
        : const AccountDeleteFederatedConfirm();

    context.read<AccountDeleteBloc>().add(event);
  }
}

class AccountDeletePasswordWarning extends StatelessWidget {
  final InputText field;

  AccountDeletePasswordWarning({required this.field});

  @override
  Widget build(BuildContext context) {
    return ListBody(children: [
      const Text('Are you sure you want to delete your account? Please re-enter your password to continue.'),
      PasswordField(input: field),
    ]);
  }
}

class AccountDeleteSimpleWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('Are you sure you want to delete your account?');
  }
}
