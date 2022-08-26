import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search_bloc.dart';
import '../../blocs/pantry/pantry.dart';
import '../../blocs/pantry_sort/pantry_sort.dart';
import '../../blocs/foods_suggestion/foods_suggestion.dart';
import '../../pages/search_delegate/food_search_delegate.dart';
import '../../pages/search_delegate/pantry_search_delegate.dart';
import '../../resources/pantry_service.dart';
import '../../routes/routes.dart';
import '../../widgets/fab_guide.dart';
import '../../widgets/floating_action_buttons/add_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/search_icon_button.dart';
import '../../widgets/icon_buttons/settings_icon_button.dart';
import '../../widgets/snack_bars/undo_delete_snack_bar.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import 'widgets/pantry_list_view.dart';
import 'widgets/pantry_sort_popup_menu_botton.dart';

class PantryPage extends StatelessWidget {
  static String tag = 'pantry-page';

  /// Build a PantryPage with its own PantryBloc provider.
  static Widget provisioned() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (c) => PantryBloc.fromContext(c)..add(const StreamAllPantry())),
        const BlocProvider(create: PantrySortCubit.fromContext),
      ],
      child: PantryPage(),
    );
  }

  void showAddFoodSearch(BuildContext context) {
    final foodSearchBloc = BlocProvider.of<FoodSearchBloc>(context);
    final recentFoodsCubit = RecentFoodsCubit.fromContext(context);

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodSearchBloc: foodSearchBloc,
        foodSuggestionCubit: recentFoodsCubit,
        onSelect: (food) => Navigator.push(context, Routes.of(context).createPantryEntryPageRouteForFood(food)),
      ),
    );
  }

  void showPantrySearch(BuildContext context) {
    final pantryBloc = PantryBloc(pantryService: context.read<PantryService>());

    showSearch(
      context: context,
      delegate: PantrySearchDelegate(
        pantryBloc: pantryBloc,
        onSelect: (pantryEntry) {
          Navigator.push(context, Routes.of(context).createPantryEntryPageRoute(pantryEntry: pantryEntry));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(
        leading: const SettingsIconButton(),
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
        onPressed: () => showAddFoodSearch(context),
      ),
    );
  }

  Widget builder(BuildContext context, PantrySortState state) {
    if (state is PantrySortLoading) {
      return GLLoadingWidget();
    }
    if (state is PantrySortLoaded) {
      final items = state.items;
      if (items.isEmpty) {
        return const FabGuide(message: 'There is nothing in your Pantry.\nTry adding a food!');
      } else {
        return PantryListView(pantryEntries: items);
      }
    }
    if (state is PantrySortError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }

  void listener(BuildContext context, PantryState state) {
    if (state is PantryEntryDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(UndoDeleteSnackBar(
        name: state.pantryEntry.foodReference.name,
        onUndelete: () => context.read<PantryBloc>().add(UndeletePantryEntry(state.pantryEntry)),
      ));
    }
  }
}
