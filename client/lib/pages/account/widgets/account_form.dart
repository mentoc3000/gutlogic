import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/application_user.dart';
import '../models/account_input_group.dart';
import 'account_form_widgets.dart';

class AccountForm extends StatelessWidget {
  final ApplicationUser user;

  AccountForm({required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return AccountInputGroup(
          firstname: user.firstname,
          lastname: user.lastname,
        );
      },
      child: ListView(
        children: [
          const SizedBox(height: 20),
          AccountFormFirstName(),
          const SizedBox(height: 20),
          AccountFormLastName(),
          const SizedBox(height: 20),
          AccountFormChangePasswordButton(),
          const SizedBox(height: 20),
          AccountFormSaveButton(),
          const SizedBox(height: 20),
          AccountFormLogoutButton(),
          const SizedBox(height: 20),
          AccountFormDeleteButton(),
        ],
      ),
    );
  }
}
