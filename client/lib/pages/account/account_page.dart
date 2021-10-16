import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/account_page_widgets.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Account'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            AccountPageChangePasswordButton(),
            const SizedBox(height: 20),
            AccountPageLogoutButton(),
            const SizedBox(height: 20),
            AccountPageDeleteButton(),
          ],
        ),
      ),
    );
  }
}
