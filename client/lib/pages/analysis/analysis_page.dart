import 'package:flutter/material.dart';

import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/settings_icon_button.dart';
import 'widgets/analysis_list_view.dart';

class AnalysisPage extends StatelessWidget {
  static String tag = 'diary-page';

  const AnalysisPage();

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Analysis', leading: const SettingsIconButton()),
      body: AnalysisListView.provisioned(),
    );
  }
}
