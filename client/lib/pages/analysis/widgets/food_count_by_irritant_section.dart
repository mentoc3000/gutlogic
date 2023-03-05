import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../blocs/food_count_by_irritant/food_count_by_irritant.dart';
import '../../../models/sensitivity/sensitivity_level.dart';
import '../../../routes/routes.dart';
import '../../../widgets/gl_calculating_widget.dart';
import '../../../widgets/gl_error_widget.dart';
import '../../../widgets/sensitivity_level_pie_chart.dart';
import 'analysis_content_card.dart';
import 'analysis_section.dart';
import 'insufficient_data.dart';

class FoodCountByIrritantSection extends StatelessWidget {
  const FoodCountByIrritantSection({Key? key}) : super(key: key);

  /// Build a [FoodCountByIrritantSection] with its own Bloc provider
  static Widget provisioned() {
    return BlocProvider(
      create: (context) => FoodCountByIrritantCubit.fromContext(context),
      child: const FoodCountByIrritantSection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const heading = 'Pantry foods by irritant';
    final subscribedContent = BlocBuilder<FoodCountByIrritantCubit, FoodCountByIrritantState>(builder: builder);
    final exampleContent = _IrritantSensitivityMatrixCardContent(matrix: _exampleData());
    return AnalysisSection(heading: heading, subscribedContent: subscribedContent, exampleContent: exampleContent);
  }

  Widget sizeAndCenter(Widget child) {
    const minHeight = 300.0;
    return AnalysisContentCard(
      child: SizedBox(
        height: minHeight,
        child: Center(child: child),
      ),
    );
  }

  Widget builder(BuildContext context, FoodCountByIrritantState state) {
    if (state is FoodCountByIrritantLoading) {
      return sizeAndCenter(GLCalculatingWidget());
    }
    if (state is FoodCountByIrritantLoaded) {
      final hasData = state.foodCountByIrritant.values
          .fold<bool>(false, (acc, el) => acc || el.values.reduce((value, element) => value + element) > 0);
      if (hasData) {
        return _IrritantSensitivityMatrixCardContent(matrix: state.foodCountByIrritant);
      } else {
        // Stack needed for message widget
        return sizeAndCenter(Stack(
          children: [
            InsufficientData(
              onTap: () => DefaultTabController.of(context).animateTo(2),
              message: 'Add foods to the Pantry',
            ),
          ],
        ));
      }
    }
    if (state is FoodCountByIrritantError) {
      return sizeAndCenter(GLErrorWidget(message: state.message));
    }
    return sizeAndCenter(const GLErrorWidget());
  }

  BuiltMap<String, BuiltMap<SensitivityLevel, int>> _exampleData() {
    return BuiltMap({
      'Fructan': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 1,
        SensitivityLevel.mild: 2,
        SensitivityLevel.moderate: 4,
        SensitivityLevel.severe: 6,
        SensitivityLevel.unknown: 1,
      }),
      'Fructose': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 6,
        SensitivityLevel.mild: 2,
        SensitivityLevel.moderate: 2,
        SensitivityLevel.severe: 0,
        SensitivityLevel.unknown: 1,
      }),
      'Sorbitol': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 4,
        SensitivityLevel.mild: 5,
        SensitivityLevel.moderate: 2,
        SensitivityLevel.severe: 2,
        SensitivityLevel.unknown: 2,
      }),
      'Mannitol': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 7,
        SensitivityLevel.mild: 3,
        SensitivityLevel.moderate: 1,
        SensitivityLevel.severe: 0,
        SensitivityLevel.unknown: 1,
      }),
      ' Lactose': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 5,
        SensitivityLevel.mild: 4,
        SensitivityLevel.moderate: 3,
        SensitivityLevel.severe: 2,
        SensitivityLevel.unknown: 1,
      }),
      'GOS': BuiltMap<SensitivityLevel, int>({
        SensitivityLevel.none: 2,
        SensitivityLevel.mild: 2,
        SensitivityLevel.moderate: 3,
        SensitivityLevel.severe: 3,
        SensitivityLevel.unknown: 1,
      }),
    });
  }
}

class _IrritantSensitivityMatrixCardContent extends StatelessWidget {
  final BuiltMap<String, BuiltMap<SensitivityLevel, int>> matrix;

  const _IrritantSensitivityMatrixCardContent({Key? key, required this.matrix}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = MediaQuery.of(context).size.shortestSide / 11;
    final entries = matrix.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final boxes = entries
        .map((e) => _IrritantPieChartCard(
              pieChart: SensitivityLevelPieChart(
                foodCount: e.value,
                radius: radius,
              ),
              irritantName: e.key,
            ))
        .toList();

    return AlignedGridView.count(
      crossAxisCount: min(3, matrix.length),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: boxes.length,
      itemBuilder: (context, index) => boxes[index],
    );
  }
}

class _IrritantPieChartCard extends StatelessWidget {
  final Widget pieChart;
  final String irritantName;

  const _IrritantPieChartCard({
    required this.pieChart,
    required this.irritantName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Column(children: [
          pieChart,
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(irritantName),
          ),
        ]),
        onTap: () =>
            Navigator.push(context, Routes.of(context).createFoodsWithIrritantPageRoute(irritantName: irritantName)),
      ),
    );
  }
}
