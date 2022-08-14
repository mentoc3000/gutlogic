import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/similar_foods/similar_foods.dart';
import '../../../models/food_reference/food_reference.dart';
import '../../error_page.dart';
import '../../loading_page.dart';
import 'similar_foods_list.dart';

class SimilarFoods extends StatelessWidget {
  final FoodReference food;

  const SimilarFoods({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => SimilarFoodsCubit.fromContext(c, food: food),
      child: BlocBuilder<SimilarFoodsCubit, SimilarFoodsState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, SimilarFoodsState state) {
    if (state is SimilarFoodsLoading) {
      return LoadingPage();
    }
    if (state is SimilarFoodsLoaded) {
      return SimilarFoodsList(foods: state.foods, maxIntensities: state.maxIntensities);
    }
    if (state is SimilarFoodsError) {
      return ErrorPage(message: state.message);
    }
    return const ErrorPage();
  }
}
