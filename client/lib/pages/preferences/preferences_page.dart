import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/pages/preferences/widgets/preferences_list_view.dart';
import 'package:gutlogic/widgets/gl_error_widget.dart';
import 'package:gutlogic/widgets/gl_loading_widget.dart';

import '../../blocs/preferences/preferences.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';

class PreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Prefences'),
      body: PreferencesCubit.provider(
        child: _PreferencesPageBody(),
      ),
    );
  }
}

class _PreferencesPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: builder,
    );
  }

  Widget builder(BuildContext context, PreferencesState state) {
    if (state is PreferencesLoading) {
      return Center(child: GLLoadingWidget());
    }
    if (state is PreferencesLoaded) {
      final cubit = context.read<PreferencesCubit>();
      return PreferencesListView(
        irritants: state.irritants,
        preferences: state.preferences,
        onIrritantFilterChanged: cubit.updateIrritantFilter,
      );
    }
    if (state is PreferencesFailure) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
