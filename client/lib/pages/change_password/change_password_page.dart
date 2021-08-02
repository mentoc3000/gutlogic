import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/change_password/change_password.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';
import 'widgets/change_password_form.dart';

class ChangePasswordPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider<ChangePasswordBloc>(
      create: (context) => ChangePasswordBloc.fromContext(context),
      child: ChangePasswordPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Change Password'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ChangePasswordForm(),
          ),
        ],
      ),
    );
  }

  void listener(BuildContext context, ChangePasswordState state) {
    if (state is ChangePasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(text: state.message));
    } else if (state is ChangePasswordSuccess) {
      Navigator.of(context).pop();
    }
  }
}
