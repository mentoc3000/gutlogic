import 'package:flutter/material.dart';

import '../../blocs/user_cubit.dart';
import '../../models/user/application_user.dart';
import '../../resources/legal_service.dart';
import '../../routes/routes.dart';
import '../../util/widget_utils.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_icons.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/info_container.dart';
import '../../widgets/list_tiles/push_list_tile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Settings'),
      body: SettingsPageBody(),
    );
  }
}

class SettingsPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthenticatedUserBuilder(builder: builder);
  }

  Widget builder(BuildContext context, ApplicationUser user) {
    final tiles = WidgetUtils.separate([
      SettingsAccountTile(),
      if (user.anonymous == false) SettingsProfileTile(),
      SettingsPreferencesTile(),
      SettingsPrivacyTile(),
      SettingsTermsOfUseTile(),
    ], separator: const Divider(color: Colors.grey));

    return SingleChildScrollView(
      child: Column(children: [
        if (user.anonymous) SettingsAnonymousAlert(),
        ...tiles,
      ]),
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
    return const PushListTile(
      heading: 'Privacy Policy',
      leading: Icon(GLIcons.privacy),
      onTap: LegalService.openPrivacyPolicy,
    );
  }
}

class SettingsTermsOfUseTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PushListTile(
      heading: 'Terms of Use',
      leading: Icon(GLIcons.license),
      onTap: LegalService.openTermsOfUse,
    );
  }
}

class SettingsPreferencesTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PushListTile(
      heading: 'Preferences',
      leading: const Icon(GLIcons.preferences),
      onTap: () => Navigator.push(context, Routes.of(context).preferences),
    );
  }
}

class SettingsAnonymousAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: InfoContainer(
        child: Text(
          'Thanks for trying Gut Logic! Create an account to backup your data and access it from multiple devices.',
        ),
      ),
    );
  }
}
