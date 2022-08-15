import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/analysis/analysis.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/settings_icon_button.dart';
import '../../widgets/gl_loading_widget.dart';
import 'widgets/analysis_list_view.dart';

class AnalysisPage extends StatelessWidget {
  static String tag = 'diary-page';

  /// Build a AnalysisPage with its own AnalysisBloc provider.
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => AnalysisCubit(),
      child: AnalysisPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Analysis', leading: const SettingsIconButton()),
      body: BlocBuilder<AnalysisCubit, AnalysisState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, AnalysisState state) {
    if (state is AnalysisLoading) {
      return GLLoadingWidget();
    }
    if (state is AnalysisLoaded) {
      return const AnalysisListView();
    }
    if (state is AnalysisError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
