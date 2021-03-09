import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/meal_entry/meal_entry.dart';
import '../../models/diary_entry/meal_entry.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/meal_entry_list_view.dart';

class MealEntryPage extends StatelessWidget {
  static String tag = 'meal-entry-page';
  final TextEditingController _notesController = TextEditingController();

  static Widget forNewEntry() {
    return BlocProvider(
      create: (context) => MealEntryBloc.fromContext(context)..add(const CreateAndStreamMealEntry()),
      child: MealEntryPage(),
    );
  }

  static Widget forExistingEntry(MealEntry entry) {
    return BlocProvider(
      create: (context) => MealEntryBloc.fromContext(context)..add(StreamMealEntry(entry)),
      child: MealEntryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Meal/Snack'),
      body: BlocConsumer<MealEntryBloc, MealEntryState>(
        builder: builder,
        listener: listener,
        listenWhen: listenWhen,
      ),
    );
  }

  void listener(BuildContext context, MealEntryState state) {
    if (state is MealEntryLoaded) {
      _notesController.text = state.diaryEntry.notes;
    }
    if (state is MealElementDeleted) {
      final snackBar = UndoDeleteSnackBar(
        name: state.mealElement.foodReference.name,
        onUndelete: () => MealEntryBloc.fromContext(context)
            .add(UndeleteMealElement(mealEntry: state.mealEntry, mealElement: state.mealElement)),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  bool listenWhen(MealEntryState previousState, MealEntryState currentState) {
    final loadedAfterSomethingElse = currentState is MealEntryLoaded && !(previousState is MealEntryLoaded);
    final deleted = currentState is MealElementDeleted;
    return loadedAfterSomethingElse || deleted;
  }

  Widget builder(BuildContext context, MealEntryState state) {
    if (state is MealEntryLoading) {
      return LoadingPage();
    }

    if (state is MealEntryLoaded) {
      final mealEntry = state.diaryEntry as MealEntry;
      return MealEntryListView(mealEntry: mealEntry, notesController: _notesController);
    }

    if (state is MealEntryError) {
      return ErrorPage(message: state.message);
    }

    return ErrorPage();
  }
}
