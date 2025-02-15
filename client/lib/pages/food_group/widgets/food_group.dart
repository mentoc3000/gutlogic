import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food_group/food_group.dart';
import '../../../widgets/gl_error_widget.dart';
import '../../../widgets/gl_loading_widget.dart';
import 'food_group_list.dart';

class FoodGroup extends StatelessWidget {
  final String group;

  const FoodGroup({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => FoodGroupCubit.fromContext(c, group: group),
      child: BlocBuilder<FoodGroupCubit, FoodGroupState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, FoodGroupState state) {
    if (state is FoodGroupLoading) {
      return GLLoadingWidget();
    }
    if (state is FoodGroupLoaded) {
      return FoodGroupList(foods: state.foods, maxIntensities: state.maxIntensities);
    }
    if (state is FoodGroupError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
