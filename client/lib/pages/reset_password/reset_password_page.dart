import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/reset_password/reset_password.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/reset_password_form.dart';

class ResetPasswordPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<ResetPasswordBloc>(
      create: (context) => ResetPasswordBloc.fromContext(context),
      child: ResetPasswordPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ResetPasswordForm(),
      ),
    );
  }
}
