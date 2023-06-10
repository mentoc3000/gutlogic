import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/recent_severity/recent_severity.dart';
import '../../../models/severity.dart';
import '../../../util/date_time_ext.dart';
import '../../../widgets/gl_calculating_widget.dart';
import '../../../widgets/gl_error_widget.dart';
import '../../../widgets/severity_indicator.dart';
import 'analysis_content_card.dart';
import 'analysis_section.dart';
import 'insufficient_data.dart';

class RecentSeveritySection extends StatelessWidget {
  static int dateCount = 7;

  const RecentSeveritySection({Key? key}) : super(key: key);

  static Widget provisioned() {
    return BlocProvider(
      create: (context) => RecentSeverityCubit.fromContext(context, dateCount: dateCount),
      child: const RecentSeveritySection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const heading = 'Recent symptom severity';
    final subscribedContent = AnalysisContentCard(
      child: BlocBuilder<RecentSeverityCubit, RecentSeverityState>(builder: builder),
    );
    final exampleContent = AnalysisContentCard(
      child: _RecentSeverityChart(recentSeverities: _exampleData()),
    );
    return AnalysisSection(heading: heading, subscribedContent: subscribedContent, exampleContent: exampleContent);
  }

  Widget sizeAndCenter(Widget child) {
    // This is a hack to get the loading to be the same size as the content
    final dummy = Opacity(
      opacity: 0.0,
      child: _RecentSeverityChart(recentSeverities: _exampleData()),
    );
    return Stack(
      alignment: Alignment.center,
      children: [dummy, child],
    );
  }

  Widget builder(BuildContext context, RecentSeverityState state) {
    if (state is RecentSeverityLoading) {
      return sizeAndCenter(GLCalculatingWidget());
    }
    if (state is RecentSeverityLoaded) {
      final hasData = state.recentSeverities.values.fold<bool>(false, (acc, el) => acc || el != null);
      final recentSeveritiesEntries = state.recentSeverities.entries.sortedBy((e) => e.key);
      return Stack(children: [
        _RecentSeverityChart(recentSeverities: recentSeveritiesEntries),
        if (!hasData)
          InsufficientData(
            onTap: () => DefaultTabController.of(context).animateTo(1),
            message: 'Start tracking symptoms',
          ),
      ]);
    }
    if (state is RecentSeverityError) {
      return sizeAndCenter(GLErrorWidget(message: state.message));
    }
    return sizeAndCenter(const GLErrorWidget());
  }

  List<MapEntry<DateTime, Severity?>> _exampleData() {
    final severities = [
      Severity.moderate,
      null,
      Severity.severe,
      Severity.moderate,
      Severity.intense,
      Severity.mild,
      null,
    ];
    final now = DateTime.now();
    final daysCount = severities.length;
    final dates = Iterable.generate(daysCount, (index) => now.subtract(Duration(days: daysCount - index - 1)));
    return Map.fromIterables(dates, severities).entries.toList();
  }
}

class _RecentSeverityChart extends StatelessWidget {
  final List<MapEntry<DateTime, Severity?>> recentSeverities;

  const _RecentSeverityChart({Key? key, required this.recentSeverities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barGroups = recentSeverities.map(buildBarGroup).toList();
    final severityIndicatorDiameter = min(MediaQuery.of(context).size.shortestSide / 12, 48.0);
    const aspectRatio = 1.2;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 16.0),
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            minY: 0.0,
            maxY: 3.5,
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: buildBottomTitles,
                  reservedSize: 36.0,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => buildLeftTitles(value, meta, severityIndicatorDiameter),
                  reservedSize: severityIndicatorDiameter,
                  interval: 0.5, // ensure severity indicators are shown
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(
              show: false,
              border: const Border(
                bottom: BorderSide(),
                left: BorderSide(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData buildBarGroup(MapEntry<DateTime, Severity?> entry) {
    final x = recentSeverities.length - 1 - entry.key.difference(recentSeverities.first.key).inDays;
    const width = 16.0;
    final severity = entry.value;
    final barRod = (severity != null)
        ? BarChartRodData(
            toY: _severityToY(severity), color: SeverityIndicator.headColorFromSeverity(severity), width: width)
        : BarChartRodData(toY: 0, width: width);
    return BarChartGroupData(x: x, barRods: [barRod]);
  }

  Widget buildBottomTitles(double value, TitleMeta meta) {
    late final Text text;
    final date = recentSeverities[recentSeverities.length - value.toInt() - 1].key;
    if (date == DateTime.now().toLocalMidnight()) {
      text = const Text('Today');
    } else {
      final weekday = recentSeverities[recentSeverities.length - value.toInt() - 1].key.weekdayAbbrevString();
      text = Text(weekday);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16.0, //margin top
      child: text,
    );
  }

  Widget buildLeftTitles(double value, TitleMeta meta, double diameter) {
    final severity = _yToSeverity(value);
    if (severity == null) return Container();
    late final severityIndicator = SeverityIndicator.fromSeverity(severity: severity, circleDiameter: diameter);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0.0,
      child: severityIndicator,
    );
  }

  double _severityToY(Severity severity) {
    switch (severity) {
      case (Severity.mild):
        return 0.5;
      case (Severity.moderate):
        return 1.5;
      case (Severity.intense):
        return 2.5;
      case (Severity.severe):
        return 3.5;
      default:
        return 0.0;
    }
  }

  Severity? _yToSeverity(double y) {
    if (y == 0.5) return Severity.mild;
    if (y == 1.5) return Severity.moderate;
    if (y == 2.5) return Severity.intense;
    if (y == 3.5) return Severity.severe;
    return null;
  }
}
