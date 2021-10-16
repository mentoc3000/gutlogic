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
    final items = [
      SettingsAccountTile(),
      SettingsProfileTile(),
      SettingsPrivacyTile(),
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

class SettingsProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PushListTile(
      heading: 'Profile',
      leading: const Icon(GLIcons.profile),
      onTap: () => Navigator.push(context, Routes.of(context).profile),
    );
  }
}

class SettingsAccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PushListTile(
      heading: 'Account',
      leading: const Icon(GLIcons.account),
      onTap: () => Navigator.push(context, Routes.of(context).account),
    );
  }
}

class SettingsPrivacyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PushListTile(
      heading: 'Privacy Policy',
      leading: const Icon(GLIcons.privacy),
      onTap: _openPrivacyPolicy,
    );
  }

  void _openPrivacyPolicy() async {
    const url = 'http://gutlogic.co/gut_logic_privacy_policy.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
