import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food_search/food_search_bloc.dart';
import '../../blocs/recent_foods/recent_foods_cubit.dart';
import '../../routes/routes.dart';
import '../../widgets/floating_action_buttons/search_floating_action_button.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../search_delegate/food_search_delegate.dart';
import 'widgets/food_group.dart';

class FoodGroupPage extends StatelessWidget {
  final String group;

  const FoodGroupPage({Key? key, required this.group}) : super(key: key);

  void showFoodSearch(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodSearchBloc>(context);
    final recentFoodsCubit = BlocProvider.of<RecentFoodsCubit>(context);

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        recentFoodsCubit: recentFoodsCubit,
        onSelect: (food) => Navigator.push(context, Routes.of(context).createFoodPageRoute(food)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: group),
      body: FoodGroup(group: group),
      floatingActionButton: SearchFloatingActionButton(
        onPressed: () => showFoodSearch(context),
      ),
    );
  }
}
