import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/register/register.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/snack_bars/error_snack_bar.dart';
import 'register_form_password.dart';
import 'register_form_username.dart';

class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _isValidForm = false;

  @override
  void initState() {
    super.initState();
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
      _isValidForm = (_formKey.currentState?.validate() ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(listener: listener, builder: builder);
  }

  void listener(BuildContext context, RegisterState state) {
    if (state is RegisterError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    }
  }

  Widget builder(BuildContext context, RegisterState state) {
    final isSubmittable = state is RegisterReady && _isValidForm;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          RegisterFormUsername(controller: _usernameTextController),
          RegisterFormPassword(controller: _passwordTextController),
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
    context.read<RegisterBloc>().add(RegisterSubmitted(
          username: _usernameTextController.text,
          password: _passwordTextController.text,
        ));
  }

  void cancel() {
    Navigator.pop(context);
  }
}
