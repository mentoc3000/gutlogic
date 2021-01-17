import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/register/register.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/email_form_field.dart';
import '../../../widgets/form_fields/password_form_field.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';

class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _isValidForm = false;
  final String Function(String) _usernameValidator = EmailValidators.full;
  final String Function(String) _passwordValidator = PasswordValidators.isNotEmpty;

  RegisterBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.bloc<RegisterBloc>();
    _usernameTextController.addListener(validateForm);
    _passwordTextController.addListener(validateForm);
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  void validateForm() {
    setState(() {
      // Check if the email and password will be valid after typing is complete
      final isValidUsername = _usernameValidator(_usernameTextController.text) == null;
      final isValidPassword = _passwordValidator(_passwordTextController.text) == null;

      _isValidForm = (_formKey.currentState?.validate() ?? false) && isValidPassword && isValidUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(listener: listener, builder: builder);
  }

  void listener(BuildContext context, RegisterState state) {
    if (state is RegisterError) {
      Scaffold.of(context).showSnackBar(buildErrorSnackBar(state.message));
    }
  }

  Widget builder(BuildContext context, RegisterState state) {
    final isSubmittable = state is RegisterReady &&
        _isValidForm &&
        _usernameTextController.text.isNotEmpty &&
        _passwordTextController.text.isNotEmpty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          EmailFormField(
            controller: _usernameTextController,
            validator: _usernameValidator,
          ),
          PasswordFormField(
            controller: _passwordTextController,
            validator: _passwordValidator,
            showStrengthBar: true,
          ),
          const Spacer(),
          GLPrimaryButton(
            child: const StretchedButtonContent(label: 'Register'),
            onPressed: isSubmittable ? onRegisterButtonPressed : null,
          ),
        ],
      ),
    );
  }

  void onRegisterButtonPressed() {
    _bloc.add(RegisterSubmitted(
      username: _usernameTextController.text,
      password: _passwordTextController.text,
    ));
  }

  void cancel() {
    Navigator.pop(context);
  }

  static Widget buildErrorSnackBar(String error) => ErrorSnackBar(text: error);
}
