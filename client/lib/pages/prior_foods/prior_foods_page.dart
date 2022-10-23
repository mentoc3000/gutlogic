import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/recent_foods/recent_foods.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_scaffold.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import 'widgets/prior_foods_list_view.dart';

class PriorFoodsPage extends StatelessWidget {
  const PriorFoodsPage({Key? key}) : super(key: key);

  static Widget provisioned({required DateTime priorTo}) {
    const duration = Duration(days: 3);
    final start = priorTo.subtract(duration);
    return BlocProvider(
      create: (context) => RecentFoodsCubit.fromContext(context, start: start, end: priorTo),
      child: const PriorFoodsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: 'Prior Foods Eaten'),
      body: BlocBuilder<RecentFoodsCubit, RecentFoodsState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, RecentFoodsState state) {
    if (state is RecentFoodsLoading) {
      return GLLoadingWidget();
    }
    if (state is RecentFoodsLoaded) {
      return PriorFoodsListView(recentFoods: state.recentFoods);
    }
    if (state is RecentFoodsError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
