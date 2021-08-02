import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/login_input_group.dart';
import 'login_form_widgets.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return LoginInputGroup();
      },
      child: Column(
        children: [
          const Spacer(),
          LoginFormUsername(),
          LoginFormPassword(),
          const Spacer(),
          LoginFormSubmitButton(),
          LoginFormResetPasswordButton(),
        ],
      ),
    );
  }
}
