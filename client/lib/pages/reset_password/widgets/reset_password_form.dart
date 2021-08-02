import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/reset_password/reset_password.dart';
import '../models/reset_password_input_group.dart';
import 'reset_password_done.dart';
import 'reset_password_form_widgets.dart';

class ResetPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.select((ResetPasswordBloc bloc) => bloc.state);

    if (state is ResetPasswordSuccess) {
      return ResetPasswordDone(email: state.email);
    }

    return BlocProvider(
      create: (context) => ResetPasswordInputGroup(),
      child: Column(
        children: [
          const Text('No problem, we all forget things sometimes. Where should we send your reset link?'),
          ResetPasswordEmail(),
          ResetPasswordSubmitButton(),
        ],
      ),
    );
  }
}
