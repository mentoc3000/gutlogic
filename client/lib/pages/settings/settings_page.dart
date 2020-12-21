import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/routes.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_icons.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/list_tiles/push_list_tile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accountTile = PushListTile(
      heading: 'Account',
      leading: const Icon(GLIcons.account),
      onTap: () => Navigator.push(context, Routes.of(context).account),
    );

    final privacyPolicyTile = PushListTile(
      heading: 'Privacy Policy',
      leading: const Icon(GLIcons.privacy),
      onTap: () async {
        const url = 'http://gutlogic.co/gut_logic_privacy_policy.pdf';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );

    final items = [
      accountTile,
      privacyPolicyTile,
    ];

    return GLScaffold(
      appBar: GLAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
          separatorBuilder: (context, index) => const Divider(color: Colors.grey),
          physics: const AlwaysScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
