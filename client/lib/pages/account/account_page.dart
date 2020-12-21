import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account/account.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
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
        // TODO: make padding consistent with the rest of the app
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AccountForm(),
      ),
    );
  }
}
