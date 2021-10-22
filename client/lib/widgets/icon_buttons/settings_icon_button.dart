import 'package:flutter/material.dart';
import '../../routes/routes.dart';

import '../gl_icons.dart';

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(GLIcons.settings),
      tooltip: 'Settings',
      onPressed: () => Navigator.push(context, Routes.of(context).settings),
    );
  }
}
