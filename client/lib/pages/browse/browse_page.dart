import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search.dart';
import '../../routes/routes.dart';
import '../../widgets/floating_action_buttons/search_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/icon_buttons/settings_icon_button.dart';
import '../search_delegate/food_search_delegate.dart';
import 'widgets/food_groups.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({Key? key}) : super(key: key);

  void showFoodSearch(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodSearchBloc>(context);

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: (food) => Navigator.push(context, Routes.of(context).createFoodPageRoute(food.toFoodReference())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(
        leading: const SettingsIconButton(),
        title: 'Browse',
      ),
      body: const FoodGroups(),
      floatingActionButton: SearchFloatingActionButton(
        onPressed: () => showFoodSearch(context),
      ),
    );
  }
}
