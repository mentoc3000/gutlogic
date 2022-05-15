import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../style/gl_colors.dart';
import '../../widgets/buttons/buttons.dart';
import '../../widgets/buttons/gl_raised_button.dart';
import '../../widgets/info_container.dart';
import '../services/auth_email.dart';
import 'auth_email_cubit.dart';

class AuthEmailGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthEmailGroupState();
}

class _AuthEmailGroupState extends State<AuthEmailGroup> {
  String _email = '';
  bool _valid = true;

  @override
  Widget build(BuildContext context) {
    final state = context.select((AuthEmailCubit cubit) => cubit.state);

    return Column(children: [
      AuthEmailInput(valid: _valid, enabled: (state is AuthEmailInitial), onChanged: _update),
      const Gap(10),
      if (state is AuthEmailInitial) AuthEmailSubmitButton(onPressed: () => _submit(context)),
      if (state is AuthEmailAwaitingLink) AuthEmailPendingGroup(email: state.email, onCanceled: () => _cancel(context)),
    ]);
  }

  void _update(String? email) {
    setState(() => _email = email ?? '');
    setState(() => _valid = true);
  }

  void _submit(BuildContext context) {
    setState(() => _valid = EmailValidator.validate(_email));
    if (_valid) context.read<AuthEmailCubit>().authenticate(service: context.read<EmailAuthService>(), email: _email);
  }

  void _cancel(BuildContext context) {
    context.read<AuthEmailCubit>().cancel();
  }
}

class AuthEmailPendingGroup extends StatelessWidget {
  final String email;

  final VoidCallback? onCanceled;

  const AuthEmailPendingGroup({required this.email, required this.onCanceled});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AuthEmailPendingInfo(email: email),
      const Gap(10),
      AuthEmailCancelButton(onPressed: onCanceled),
    ]);
  }
}

class AuthEmailPendingInfo extends StatelessWidget {
  final String email;

  const AuthEmailPendingInfo({required this.email});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InfoContainer(
        child: Text(
          'We sent a secure sign-in link to $email. Please check your email.',
          style: const TextStyle(color: GLColors.white),
        ),
      ),
    );
  }
}

class AuthEmailSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthEmailSubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLPrimaryButton(
      onPressed: onPressed,
      child: const StretchedButtonContent(label: 'Continue with email'),
    );
  }
}

class AuthEmailCancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthEmailCancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GLRaisedButton(
      color: GLColors.cancel,
      textColor: GLColors.white,
      onPressed: onPressed,
      child: const StretchedButtonContent(label: 'Use different email'),
    );
  }
}

class AuthEmailSuccessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const InfoContainer(child: Text("You're all set!"));
  }
}

class AuthEmailInput extends StatelessWidget {
  final bool valid;
  final bool enabled;
  final Function(String?) onChanged;

  const AuthEmailInput({required this.enabled, required this.valid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: 'Email',
        errorText: valid ? null : 'Invalid email',
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      onChanged: onChanged,
    );
  }
}
