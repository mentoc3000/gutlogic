import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/register_input_group.dart';
import 'register_form_widgets.dart';

class RegisterForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return RegisterInputGroup();
      },
      child: Column(
        children: [
          const Spacer(),
          RegisterFormUsername(),
          RegisterFormPassword(),
          const Spacer(),
          RegisterFormSubmitButton(),
        ],
      ),
    );
  }
}
