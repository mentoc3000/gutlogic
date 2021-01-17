import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/reset_password/reset_password.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/form_fields/email_form_field.dart';
import 'reset_password_done.dart';

class ResetPasswordForm extends StatefulWidget {
  @override
  ResetPasswordFormState createState() => ResetPasswordFormState();
}

class ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _emailValidator = EmailValidators.full;

  bool _isValidForm = false;

  @override
  void initState() {
    super.initState();
    _emailTextController.addListener(validateForm);
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  void validateForm() {
    setState(() {
      final isValidEmail = _emailValidator(_emailTextController.text) == null;

      _isValidForm = (_formKey.currentState?.validate() ?? false) && isValidEmail;
    });
  }

  void onSubmitButtonPressed() {
    if (_formKey.currentState.validate() == false) return;

    final bloc = context.bloc<ResetPasswordBloc>();

    bloc.add(ResetPasswordSubmitted(email: _emailTextController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(builder: builder);
  }

  Widget builder(BuildContext context, ResetPasswordState state) {
    if (state is ResetPasswordSuccess) {
      return ResetPasswordDone(email: state.email);
    }

    final isSubmittable = state is ResetPasswordReady && _isValidForm;

    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        children: [
          const Text('No problem, we all forget things sometimes. Where should we send your reset link?'),
          EmailFormField(
            controller: _emailTextController,
            validator: _emailValidator,
          ),
          GLPrimaryButton(
            child: const StretchedButtonContent(label: 'Send Reset Link'),
            onPressed: isSubmittable ? onSubmitButtonPressed : null,
          ),
        ],
      ),
    );
  }
}
