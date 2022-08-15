import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food_groups/food_groups.dart';
import '../../../widgets/gl_error_widget.dart';
import '../../../widgets/gl_loading_widget.dart';
import 'food_groups_list.dart';

class FoodGroups extends StatelessWidget {
  const FoodGroups({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => FoodGroupsCubit.fromContext(c),
      child: BlocBuilder<FoodGroupsCubit, FoodGroupsState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, FoodGroupsState state) {
    if (state is FoodGroupsLoading) {
      return GLLoadingWidget();
    }
    if (state is FoodGroupsLoaded) {
      return FoodGroupsList(groups: state.groups);
    }
    if (state is FoodGroupsError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
