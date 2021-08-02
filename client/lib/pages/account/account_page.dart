import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account/account.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/info_snack_bar.dart';
import '../error_page.dart';
import 'widgets/account_form.dart';

class AccountPage extends StatelessWidget {
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => AccountBloc.fromContext(context),
      child: AccountPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Account'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocConsumer<AccountBloc, AccountState>(
          listener: listener,
          builder: builder,
        ),
      ),
    );
  }

  Widget builder(BuildContext context, AccountState state) {
    if (state is AccountUserState) {
      return AccountForm(user: (state as AccountUserState).user);
    } else {
      return ErrorPage(message: (state as AccountError).message);
    }
  }

  void listener(BuildContext context, AccountState state) {
    if (state is AccountUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(InfoSnackBar(text: 'Account updated'));
    }
  }
}
