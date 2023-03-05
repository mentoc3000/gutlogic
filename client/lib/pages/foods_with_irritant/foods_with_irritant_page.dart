import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/pages/foods_with_irritant/widgets/no_foods_with_irritant.dart';

import '../../blocs/foods_with_irritant/foods_with_irritant.dart';
import '../../widgets/gl_app_bar.dart';
import '../../widgets/gl_error_widget.dart';
import '../../widgets/gl_loading_widget.dart';
import '../../widgets/gl_scaffold.dart';
import 'widgets/foods_with_irritant_list_view.dart';

class FoodsWithIrritantPage extends StatelessWidget {
  final String irritantName;

  const FoodsWithIrritantPage({required this.irritantName});

  /// Build a AnalysisListView with its own Bloc providers.
  static Widget provisioned({required String irritantName}) {
    return BlocProvider(
      create: (context) => FoodsWithIrritantCubit.fromContext(context, irritantName: irritantName),
      child: FoodsWithIrritantPage(irritantName: irritantName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GLScaffold(
      appBar: GLAppBar(title: irritantName),
      body: BlocBuilder<FoodsWithIrritantCubit, FoodsWithIrritantState>(builder: builder),
    );
  }

  Widget builder(BuildContext context, FoodsWithIrritantState state) {
    if (state is FoodsWithIrritantLoading) {
      return GLLoadingWidget();
    }
    if (state is FoodsWithIrritantLoaded) {
      final foodCount = state.sensitivityLevelCount.values.reduce((a, b) => a + b);
      if (foodCount > 0) {
        return FoodsWithIrritantListView(
          foodsBySensitivityLevel: state.foodsBySensitivityLevel,
          sensitivityLevelCount: state.sensitivityLevelCount,
        );
      } else {
        return NoFoodsWithIrritant(irritantName: irritantName);
      }
    }
    if (state is FoodsWithIrritantError) {
      return GLErrorWidget(message: state.message);
    }
    return const GLErrorWidget();
  }
}
