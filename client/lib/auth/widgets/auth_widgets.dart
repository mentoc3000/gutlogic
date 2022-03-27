import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../auth_data.dart';
import 'auth_email_cubit.dart';
import 'auth_email_widgets.dart';
import 'auth_provider_widgets.dart';

class AuthSection extends StatelessWidget {
  final void Function(Authentication) onAuthentication;

  const AuthSection({required this.onAuthentication});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AuthEmailCubit.provider(child: AuthEmailGroup(), onAuthentication: onAuthentication),
      const Gap(20),
      AuthSectionDivider(),
      const Gap(20),
      AuthProviderGroup(onAuthentication: onAuthentication),
    ]);
  }
}

class AuthSectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or')),
      Expanded(child: Divider(thickness: 1, color: Colors.grey)),
    ]);
  }
}
