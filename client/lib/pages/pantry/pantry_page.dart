import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food/food_bloc.dart';
import '../../blocs/pantry/pantry.dart';
import '../../blocs/pantry_filter/pantry_filter.dart';
import '../../blocs/pantry_sort/pantry_sort.dart';
import '../../pages/search_delegate/food_search_delegate.dart';
import '../../pages/search_delegate/pantry_search_delegate.dart';
import '../../resources/pantry_repository.dart';
import '../../routes/routes.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/filter_icon_button.dart';
import '../../widgets/icon_buttons/search_icon_button.dart';
import '../../widgets/list_tiles/gl_list_tile.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/pantry_filter_widget.dart';
import 'widgets/pantry_list_view.dart';
import 'widgets/pantry_sort_popup_menu_botton.dart';

class PantryPage extends StatelessWidget {
  static String tag = 'pantry-page';

  /// Build a PantryPage with its own PantryBloc provider.
  static Widget provisioned() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PantryBloc.fromContext(context)..add(const StreamAllPantry())),
        BlocProvider(create: (context) => PantryFilterCubit.fromContext(context)),
        BlocProvider(create: (context) => PantrySortCubit.fromContext(context)),
      ],
      child: PantryPage(),
    );
  }

  void showFoodSearch(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodBloc>(context);

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: (food) =>
            Navigator.push(context, Routes.of(context).createNewPantryEntryPageRouteForFood(food: food)),
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

  void showPantryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return PantryFilterWidget(pantryFilterCubit: context.read<PantryFilterCubit>());
      },
      elevation: 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(
        leading: Builder(builder: (context) => FilterIconButton(onPressed: () => showPantryFilter(context))),
        title: 'Pantry',
        actions: [
          PantrySortPopupMenuButton(onSelected: (sort) => context.read<PantrySortCubit>().sortBy(sort)),
          SearchIconButton(onPressed: () => showPantrySearch(context)),
        ],
      ),
      body: BlocListener<PantryBloc, PantryState>(
        listener: listener,
        child: BlocBuilder<PantrySortCubit, PantrySortState>(
          builder: builder,
        ),
      ),
      floatingActionButton: AddFloatingActionButton(
        onPressed: () => showFoodSearch(context),
      ),
    );
  }

  Widget builder(BuildContext context, PantrySortState state) {
    if (state is PantrySortLoading) {
      return LoadingPage();
    }
    if (state is PantrySortLoaded) {
      final items = state.items;
      if (items.isEmpty) {
        return const GLListTile(heading: 'There is nothing in your pantry. Try adding a food!');
      } else {
        return PantryListView(pantryEntries: items);
      }
    }
    if (state is PantrySortError) {
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
