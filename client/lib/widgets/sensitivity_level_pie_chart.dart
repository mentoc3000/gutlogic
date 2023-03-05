import 'package:built_collection/built_collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/sensitivity/sensitivity_level.dart';
import '../style/gl_colors.dart';

class SensitivityLevelPieChart extends StatelessWidget {
  final double radius;
  final BuiltMap<SensitivityLevel, int> foodCount;

  const SensitivityLevelPieChart({required this.foodCount, required this.radius});

  @override
  Widget build(BuildContext context) {
    late final Widget pieChart;
    final totalCount = foodCount.values.fold<int>(0, (a, b) => a + b);

    if (totalCount > 0) {
      final entries = foodCount.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final sections = entries.map((entry) {
        return PieChartSectionData(
          value: entry.value.toDouble(),
          title: entry.value.toString(),
          color: GLColors.fromSensitivityLevel(entry.key),
          radius: radius,
          borderSide: BorderSide(color: GLColors.darkGray, width: 1.5),
        );
      }).toList();

      // When there is only one pie slice (i.e. the whole pie) use a -1.0 radius to remove center dot
      // The 0.25 radius tries to resolve some weirdness at the point of majority slices
      final centerSpaceRadius = foodCount.values.where((element) => element > 0).length > 1 ? 0.25 : -1.0;

      pieChart = PieChart(
        PieChartData(centerSpaceRadius: centerSpaceRadius, sections: sections),
      );
    } else {
      final sections = [
        PieChartSectionData(
          title: '',
          color: GLColors.lightestGray,
          radius: radius,
          borderSide: const BorderSide(color: GLColors.gray, width: 0.5),
        )
      ];

      // Remove center dot
      const centerSpaceRadius = -1.0;

      pieChart = PieChart(
        PieChartData(centerSpaceRadius: centerSpaceRadius, sections: sections),
      );
    }

    final width = 2.8 * radius;
    final height = 2.8 * radius;
    return SizedBox(width: width, height: height, child: pieChart);
  }
}
