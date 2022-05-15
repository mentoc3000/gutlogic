import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../blocs/user_cubit.dart';
import '../../models/application_user.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/account_page_widgets.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Account'),
      body: SingleChildScrollView(child: AccountPageBody()),
    );
  }
}

class AccountPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthenticatedUserBuilder(builder: builder);
  }

  Widget builder(BuildContext context, ApplicationUser user) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (user.anonymous) AccountPageCreateButton(),
        if (user.anonymous) const Gap(10),
        if (user.anonymous == false) AccountDetailsCard(user: user),
        if (user.anonymous == false) const Gap(10),
        if (user.anonymous == false) AccountPageLogoutButton(),
        if (user.anonymous == false) const Gap(10),
        AccountPageDeleteButton(),
      ]),
    );
  }
}
