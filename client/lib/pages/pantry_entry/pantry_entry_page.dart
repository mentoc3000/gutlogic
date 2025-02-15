import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/pantry_entry/pantry_entry.dart';
import '../../models/food_reference/food_reference.dart';
import '../../models/pantry/pantry_entry.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/gl_loading_widget.dart';
import 'widgets/pantry_entry_list_view.dart';

class PantryEntryPage extends StatelessWidget {
  static String tag = 'pantryentry-entry-page';
  final TextEditingController _notesController = TextEditingController();

  /// Wrap an pantryentry page with the necessary bloc providers, given the pantryentry.
  static Widget forPantryEntry(PantryEntry pantryEntry) {
    return BlocProvider(
      create: (context) {
        return PantryEntryBloc.fromContext(context, foodName: pantryEntry.foodReference.name)
          ..add(StreamEntry(pantryEntry));
      },
      child: PantryEntryPage(),
    );
  }

  /// Wrap an pantryentry page with the necessary bloc providers, given the meal entry.
  static Widget forFood(FoodReference foodReference) {
    return BlocProvider(
      create: (context) {
        return PantryEntryBloc.fromContext(context, foodName: foodReference.name)
          ..add(CreateAndStreamEntry(foodReference));
      },
      child: PantryEntryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryEntryBloc, PantryEntryState>(
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  void listener(BuildContext context, PantryEntryState state) {
    if (state is PantryEntryLoaded) {
      _notesController.text = state.pantryEntry.notes ?? '';
    }
  }

  bool listenWhen(PantryEntryState previousState, PantryEntryState currentState) {
    return currentState is PantryEntryLoaded && previousState is! PantryEntryLoaded;
  }

  Widget builder(BuildContext context, PantryEntryState state) {
    return GLScaffold(
      appBar: appBarBuilder(context, state),
      body: bodyBuilder(context, state),
    );
  }

  AppBar appBarBuilder(BuildContext context, PantryEntryState state) {
    if (state is PantryEntryLoaded) {
      return GLAppBar(title: state.pantryEntry.foodReference.name);
    }
    if (state is PantryEntryLoading) {
      return GLAppBar(title: state.foodName);
    }
    return GLAppBar(title: 'Food');
  }

  Widget bodyBuilder(BuildContext context, PantryEntryState state) {
    if (state is PantryEntryLoading) {
      return GLLoadingWidget();
    }
    if (state is PantryEntryLoaded) {
      return PantryEntryListView(
        pantryEntry: state.pantryEntry,
        food: state.food,
        notesController: _notesController,
        excludedIrritants: state.excludedIrritants,
      );
    }
    if (state is PantryEntryError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
