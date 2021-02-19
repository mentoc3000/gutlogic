import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food/food_bloc.dart';
import '../../blocs/pantry/pantry.dart';
import '../../pages/search_delegate/food_search_delegate.dart';
import '../../pages/search_delegate/pantry_search_delegate.dart';
import '../../resources/pantry_repository.dart';
import '../../routes/routes.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/search_icon_button.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/pantry_list_view.dart';

class PantryPage extends StatelessWidget {
  static String tag = 'pantry-page';

  /// Build a PantryPage with its own PantryBloc provider.
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => PantryBloc.fromContext(context)..add(const StreamAllPantry()),
      child: PantryPage(),
    );
  }

  void showFoodSearch(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodBloc>(context);

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: (food) => Navigator.push(context, Routes.of(context).createPantryEntryPageRouteForFood(food: food)),
      ),
    );
  }

  void showPantrySearch(BuildContext context) {
    final pantryBloc = PantryBloc(repository: context.read<PantryRepository>());

    showSearch(
      context: context,
      delegate: PantrySearchDelegate(
        pantryBloc: pantryBloc,
        onSelect: (pantryEntry) =>
            Navigator.push(context, Routes.of(context).createPantryEntryPageRoute(pantryEntry: pantryEntry)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(
        title: 'Pantry',
        actions: [SearchIconButton(onPressed: () => showPantrySearch(context))],
      ),
      body: BlocConsumer<PantryBloc, PantryState>(
        builder: builder,
        listener: listener,
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () => showFoodSearch(context),
      ),
    );
  }

  Widget builder(BuildContext context, PantryState state) {
    if (state is PantryLoading) {
      return LoadingPage();
    }
    if (state is PantryLoaded) {
      final items = state.items;
      if (items.isEmpty) {
        return const GLListTile(heading: 'There is nothing in your pantry. Try adding a food!');
      } else {
        return PantryListView(pantryEntries: items);
      }
    }
    if (state is PantryError) {
      return ErrorPage(message: state.message);
    }
    return ErrorPage();
  }

  void listener(BuildContext context, PantryState state) {
    if (state is PantryEntryDeleted) {
      final snackbar = UndoDeleteSnackBar(
        name: state.pantryEntry.foodReference.name,
        onUndelete: () => context.read<PantryBloc>().add(UndeletePantryEntry(state.pantryEntry)),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }
}
