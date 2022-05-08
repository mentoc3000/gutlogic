import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/diary/diary.dart';
import '../../util/keys.dart';
import '../../widgets/fab_guide.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/settings_icon_button.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/diary_floating_action_button.dart';
import 'widgets/diary_list_view.dart';

class DiaryPage extends StatelessWidget {
  static String tag = 'diary-page';

  /// Build a DiaryPage with its own DiaryBloc provider.
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => DiaryBloc.fromContext(context)..add(const StreamAllDiary()),
      child: DiaryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Timeline', leading: const SettingsIconButton()),
      body: BlocConsumer<DiaryBloc, DiaryState>(builder: builder, listener: listener, buildWhen: buildWhen),
      floatingActionButton: const DiaryFloatingActionButton(key: Keys.diaryFab),
    );
  }

  bool buildWhen(DiaryState previous, DiaryState current) {
    return current is DiaryLoading || current is DiaryLoaded || current is DiaryError;
  }

  Widget builder(BuildContext context, DiaryState state) {
    if (state is DiaryLoading) {
      return LoadingPage();
    }
    if (state is DiaryLoaded) {
      if (state.diaryEntries.isEmpty) {
        return const FabGuide(message: 'Start tracking here');
      }
      return DiaryListView(diaryEntries: state.diaryEntries);
    }
    if (state is DiaryError) {
      return ErrorPage(message: state.message);
    }
    return const ErrorPage();
  }

  void listener(BuildContext context, DiaryState state) {
    if (state is DiaryEntryDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(UndoDeleteSnackBar(
        name: 'entry',
        onUndelete: () => DiaryBloc.fromContext(context).add(Undelete(state.diaryEntry)),
      ));
    }
  }
}
