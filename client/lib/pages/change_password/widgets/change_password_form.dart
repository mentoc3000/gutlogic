import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/auth_provider.dart';
import '../../../blocs/change_password/change_password.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/focus_history.dart';
import '../../../widgets/form_fields/password_field.dart';
import '../../../widgets/form_fields/password_strength.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';
import 'change_password_upgrade_warning.dart';

class ChangePasswordForm extends StatefulWidget {
  @override
  ChangePasswordFormState createState() => ChangePasswordFormState();
}

class ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _currentPasswordTextController = TextEditingController();
  final TextEditingController _updatedPasswordTextController = TextEditingController();
  final TextEditingController _updatedRepeatedTextController = TextEditingController();

  bool _isValidForm = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentPasswordTextController.addListener(validateForm);
    _updatedPasswordTextController.addListener(validateForm);
    _updatedRepeatedTextController.addListener(validateForm);
  }

  @override
  void dispose() {
    _currentPasswordTextController.dispose();
    _updatedPasswordTextController.dispose();
    _updatedRepeatedTextController.dispose();
    super.dispose();
  }

  void validateForm() {
    setState(() {
      _isValidForm = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(listener: listener, builder: builder);
  }

  void onAcceptButtonPressed() {
    context.read<ChangePasswordBloc>().add(ChangePasswordSubmitted(
          currentPassword: _currentPasswordTextController.text,
          updatedPassword: _updatedPasswordTextController.text,
        ));
  }

  void listener(BuildContext context, ChangePasswordState state) {
    if (state is ChangePasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    } else if (state is ChangePasswordSuccess) {
      Navigator.of(context).pop();
    }
  }

  Widget builder(BuildContext context, ChangePasswordState state) {
    final isSubmittable = state is ChangePasswordEntry && _isValidForm;

    Widget first;

    final hasPasswordProvider = state.user.providers.contains(AuthProvider.password);

    if (hasPasswordProvider) {
      first = PasswordField(
        enabled: state is ChangePasswordEntry,
        controller: _currentPasswordTextController,
        validator: null,
        label: 'Current Password',
      );
    } else {
      first = ChangePasswordUpgradeWarning(email: state.user.email);
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          first,
          const SizedBox(height: 20),
          FocusHistory(child: Builder(builder: (context) {
            return PasswordField(
              enabled: state is ChangePasswordEntry,
              controller: _updatedPasswordTextController,
              validator: (value) {
                if (FocusHistory.of(context).blurred) return PasswordField.validate(value);
              },
              label: 'New Password',
            );
          })),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 0, 0),
            child: PasswordStrength(controller: _updatedPasswordTextController),
          ),
          const SizedBox(height: 20),
          FocusHistory(child: Builder(builder: (context) {
            return PasswordField(
              enabled: state is ChangePasswordEntry,
              controller: _updatedRepeatedTextController,
              validator: (value) {
                if (FocusHistory.of(context).blurred &&
                    _updatedPasswordTextController.text != _updatedRepeatedTextController.text) {
                  return 'Passwords must match.';
                }
              },
              label: 'Confirm Password',
            );
          })),
          const SizedBox(height: 20),
          GLPrimaryButton(
            child: const StretchedButtonContent(label: 'Save'),
            onPressed: isSubmittable ? onAcceptButtonPressed : null,
          ),
        ],
      ),
    );
  }
}
