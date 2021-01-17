import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/auth_provider.dart';
import '../../../blocs/change_password/change_password.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/password_form_field.dart';
import 'change_password_upgrade_warning.dart';

class ChangePasswordForm extends StatefulWidget {
  @override
  ChangePasswordFormState createState() => ChangePasswordFormState();
}

class ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _currentPasswordTextController = TextEditingController();
  final TextEditingController _updatedPasswordTextController = TextEditingController();
  final TextEditingController _updatedRepeatedTextController = TextEditingController();

  ChangePasswordBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.bloc<ChangePasswordBloc>();
    _currentPasswordTextController.addListener(onCurrentPasswordChanged);
    _updatedPasswordTextController.addListener(onUpdatedPasswordChanged);
    _updatedRepeatedTextController.addListener(onUpdatedRepeatedChanged);
  }

  @override
  void dispose() {
    _currentPasswordTextController.dispose();
    _updatedPasswordTextController.dispose();
    _updatedRepeatedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(listener: listener, builder: builder);
  }

  void onCurrentPasswordChanged() {
    if (_bloc.state is ChangePasswordEntry) {
      _bloc.add(ChangePasswordUpdated(
        currentPassword: _currentPasswordTextController.text,
        updatedPassword: _updatedPasswordTextController.text,
        updatedRepeated: _updatedRepeatedTextController.text,
      ));
    }
  }

  void onUpdatedPasswordChanged() {
    if (_bloc.state is ChangePasswordEntry) {
      _bloc.add(ChangePasswordUpdated(
        currentPassword: _currentPasswordTextController.text,
        updatedPassword: _updatedPasswordTextController.text,
        updatedRepeated: _updatedRepeatedTextController.text,
      ));
    }
  }

  void onUpdatedRepeatedChanged() {
    if (_bloc.state is ChangePasswordEntry) {
      _bloc.add(ChangePasswordUpdated(
        currentPassword: _currentPasswordTextController.text,
        updatedPassword: _updatedPasswordTextController.text,
        updatedRepeated: _updatedRepeatedTextController.text,
      ));
    }
  }

  void onAcceptButtonPressed() {
    if (_bloc.state is ChangePasswordEntry) {
      _bloc.add(ChangePasswordSubmitted(
        currentPassword: _currentPasswordTextController.text,
        updatedPassword: _updatedPasswordTextController.text,
      ));
    }
  }

  bool _isPasswordValid(
    ChangePasswordState state,
  ) {
    if (state is ChangePasswordEntry) {
      return _updatedPasswordTextController.text.isEmpty || state.isValid;
    } else {
      return true; // hide entry errors on other states
    }
  }

  bool _isRepeatedValid(ChangePasswordState state) {
    if (state is ChangePasswordEntry) {
      // We only show an error on the Repeat Password field if the Enter Password field is already valid.
      return _isPasswordValid(state) == false || _updatedPasswordTextController.text.isEmpty || state.isRepeated;
    } else {
      return true; // hide entry errors on other states
    }
  }

  void listener(BuildContext context, ChangePasswordState state) {
    if (state is ChangePasswordError) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(state.message)));
      context.bloc<ChangePasswordBloc>().add(ChangePasswordUpdated(
            currentPassword: _currentPasswordTextController.text,
            updatedPassword: _updatedPasswordTextController.text,
            updatedRepeated: _updatedRepeatedTextController.text,
          ));
    } else if (state is ChangePasswordSuccess) {
      Navigator.of(context).pop();
    }
  }

  Widget builder(BuildContext context, ChangePasswordState state) {
    final isAcceptButtonEnabled = state is ChangePasswordEntry && state.isValid && state.isRepeated;

    Widget first;

    final hasPasswordProvider = state.user.providers.contains(AuthProvider.password);

    if (hasPasswordProvider) {
      first = PasswordFormField(
        enabled: state is ChangePasswordEntry,
        controller: _currentPasswordTextController,
        label: 'Current Password',
        validator: PasswordValidators.isNotEmpty,
      );
    } else {
      first = ChangePasswordUpgradeWarning(email: state.user.email);
    }

    return ListView(children: [
      first,
      const SizedBox(height: 20),
      PasswordFormField(
        enabled: state is ChangePasswordEntry,
        controller: _updatedPasswordTextController,
        validator: PasswordValidators.length,
        label: 'New Password',
        showStrengthBar: true,
      ),
      const SizedBox(height: 20),
      PasswordFormField(
        enabled: state is ChangePasswordEntry,
        controller: _updatedRepeatedTextController,
        validator: (_) => _isRepeatedValid(state) ? null : 'Passwords must match.',
        label: 'Confirm Password',
      ),
      const SizedBox(height: 20),
      buildAcceptButton(onPressed: isAcceptButtonEnabled ? onAcceptButtonPressed : null),
    ]);
  }

  static Widget buildAcceptButton({VoidCallback onPressed}) {
    return GLPrimaryButton(
      child: const StretchedButtonContent(label: 'Save'),
      onPressed: onPressed,
    );
  }
}
