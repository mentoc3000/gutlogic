import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/diary_streak/diary_streak.dart';
import '../../../style/gl_colors.dart';
import '../../../util/date_time_ext.dart';
import '../../../widgets/gl_calculating_widget.dart';
import '../../../widgets/gl_error_widget.dart';
import 'analysis_card.dart';

class DiaryStreakCard extends StatelessWidget {
  static const int daysShown = 5;

  const DiaryStreakCard({Key? key}) : super(key: key);

  static Widget provisioned() {
    return BlocProvider(
      create: (context) => DiaryStreakCubit.fromContext(context, dateCount: daysShown),
      child: const DiaryStreakCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const heading = 'Timeline use streak';
    final subscribedContent = BlocBuilder<DiaryStreakCubit, DiaryStreakState>(builder: builder);
    final exampleContent = _DiaryStreakChart(diaryStreak: _exampleData());
    return AnalysisCard(heading: heading, subscribedContent: subscribedContent, exampleContent: exampleContent);
  }

  Widget sizeAndCenter(Widget child) {
    const minHeight = 72.0;
    return SizedBox(
      height: minHeight,
      child: Center(child: child),
    );
  }

  Widget builder(BuildContext context, DiaryStreakState state) {
    if (state is DiaryStreakLoading) {
      return sizeAndCenter(GLCalculatingWidget());
    }
    if (state is DiaryStreakLoaded) {
      return _DiaryStreakChart(diaryStreak: state.diaryStreak);
    }
    if (state is DiaryStreakError) {
      return sizeAndCenter(GLErrorWidget(message: state.message));
    }
    return sizeAndCenter(const GLErrorWidget());
  }

  BuiltMap<DateTime, int> _exampleData() {
    return BuiltMap<DateTime, int>({
      DateTime.now(): 3,
      DateTime.now().subtractDays(1): 2,
      DateTime.now().subtractDays(2): 1,
      DateTime.now().subtractDays(3): 0,
      DateTime.now().subtractDays(4): 2,
    });
  }
}

class _DiaryStreakChart extends StatelessWidget {
  final BuiltMap<DateTime, int> diaryStreak;

  const _DiaryStreakChart({Key? key, required this.diaryStreak}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final diaryStreakEntries = diaryStreak.entries.sortedBy((e) => e.key).toList();
    const missedColor = GLColors.gray;
    const streakColor = GLColors.darkGreen;
    const todayColor = GLColors.green;
    final now = DateTime.now().toLocalMidnight();

    final widgets = List<Widget>.generate(2 * diaryStreakEntries.length, (index) {
      if (index.isEven) {
        final i = (index / 2).floor();
        final prevCount = (i - 1) >= 0 ? diaryStreakEntries[i - 1].value : null;
        final nextCount = diaryStreakEntries[i].value;
        final endColor = i == (diaryStreakEntries.length - 1)
            ? todayColor
            : nextCount > 0
                ? streakColor
                : missedColor;
        final startColor = prevCount == null
            ? endColor
            : prevCount > 0
                ? streakColor
                : missedColor;
        return _Connector(isDashed: nextCount == 0, startColor: startColor, endColor: endColor);
      } else {
        final i = (index / 2).ceil() - 1;
        final count = diaryStreakEntries[i].value;
        final date = diaryStreakEntries[i].key.toLocalMidnight();
        final color = date.isAtSameMomentAs(now)
            ? todayColor
            : count == 0
                ? missedColor
                : streakColor;
        return _DayIndicator(count: count, date: date, color: color);
      }
    });
    widgets.add(Expanded(child: Container()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Row(children: widgets)],
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final int count;
  final DateTime date;
  final Color color;

  const _DayIndicator({required this.count, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now().toLocalMidnight().isAtSameMomentAs(date.toLocalMidnight())
        ? 'Today'
        : date.toLocalMidnight().weekdayAbbrevString();
    final text = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(day),
    );
    return Column(children: [_Count(value: count, color: color), text]);
  }
}

class _Count extends StatelessWidget {
  final int value;
  final Color color;

  const _Count({Key? key, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const diameter = 50.0;
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 5.0),
        borderRadius: BorderRadius.circular(diameter / 2),
      ),
      child: Center(child: Text(value.toString())),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isDashed;
  final Color startColor;
  final Color endColor;

  const _Connector({Key? key, required this.isDashed, required this.startColor, required this.endColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dashHeight = 3.0;
    final gradient = BoxDecoration(gradient: LinearGradient(colors: [startColor, endColor]));
    final solid = BoxDecoration(color: endColor);

    return Expanded(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final boxWidth = constraints.constrainWidth();
              final dashWidth = isDashed ? 3.0 : boxWidth;
              final dashCount = isDashed ? (boxWidth / (2 * dashWidth)).floor() : 1;
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (index) {
                  return SizedBox(
                    width: dashWidth,
                    height: dashHeight,
                    child: DecoratedBox(decoration: index == 0 ? gradient : solid),
                  );
                }),
              );
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 8.0), child: Text(' ')),
        ],
      ),
    );
  }
}
