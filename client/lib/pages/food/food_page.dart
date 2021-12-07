import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food/food.dart';
import '../../models/food_reference/food_reference.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../error_page.dart';
import '../loading_page.dart';
import 'widgets/food_list_view.dart';

class FoodPage extends StatelessWidget {
  static String tag = 'food-page';

  /// Wrap an Food page with the necessary bloc providers, given the meal entry.
  static Widget forFood(FoodReference foodReference) {
    return BlocProvider(
      create: (context) => FoodCubit.fromContext(context)..get(foodReference),
      child: FoodPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCubit, FoodState>(builder: builder);
  }

  Widget builder(BuildContext context, FoodState state) {
    return GLScaffold(
      appBar: appBarBuilder(context, state),
      body: bodyBuilder(context, state),
    );
  }

  AppBar appBarBuilder(BuildContext context, FoodState state) {
    if (state is FoodLoaded) {
      return GLAppBar(title: state.food.name);
    } else {
      return GLAppBar(title: 'Food');
    }
  }

  Widget bodyBuilder(BuildContext context, FoodState state) {
    if (state is FoodLoading) {
      return LoadingPage();
    }
    if (state is FoodLoaded) {
      return FoodListView(food: state.food);
    }
    if (state is FoodError) {
      return ErrorPage(message: state.message);
    }
    return ErrorPage();
  }
}
