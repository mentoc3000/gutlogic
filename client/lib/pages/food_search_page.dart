import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/food/food.dart';
import '../models/food/food.dart';
import '../routes/routes.dart';
import '../widgets/gl_app_bar.dart';
import '../widgets/gl_icons.dart';
import '../widgets/gl_scaffold.dart';
import 'search_delegate/food_search_delegate.dart';

class FoodSearchPage extends StatelessWidget {
  static String tag = 'foodsearch-page';

  void showFoodSearch(BuildContext context) {
    final foodBloc = BlocProvider.of<FoodBloc>(context);

    void onSelect(Food food) => Navigator.push(context, Routes.of(context).createFoodPageRoute(food: food));

    Future<void> onAdd(String foodName) async => foodBloc.add(CreateCustomFood(foodName));

    showSearch(
      context: context,
      delegate: FoodSearchDelegate(
        foodBloc: foodBloc,
        onSelect: onSelect,
        onAdd: onAdd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(
        title: 'Food',
        actions: [
          IconButton(
            icon: const Icon(GLIcons.search),
            onPressed: () => showFoodSearch(context),
          ),
        ],
      ),
      body: const Text('Search for something'),
    );
  }
}
