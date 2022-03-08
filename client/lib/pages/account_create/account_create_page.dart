import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth.dart';
import '../../blocs/account_create/account_create.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/error_snack_bar.dart';

class AccountCreatePage extends StatelessWidget {
  static Widget provisioned() => AccountCreateCubit.provider(child: AccountCreatePage());

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCreateCubit, AccountCreateState>(
      listener: listener,
      child: GLScaffold(
        appBar: GLAppBar(title: 'Create Account'),
        body: SingleChildScrollView(child: AccountCreatePageBody()),
      ),
    );
  }

  static void listener(BuildContext context, AccountCreateState state) {
    if (state is AccountCreateFailure) {
      ErrorSnackBar.show(context, state);
    } else if (state is AccountCreateSuccess) {
      Navigator.of(context).pop();
    }
  }
}

class AccountCreatePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AuthSection(onAuthentication: context.read<AccountCreateCubit>().create),
    );
  }
}
