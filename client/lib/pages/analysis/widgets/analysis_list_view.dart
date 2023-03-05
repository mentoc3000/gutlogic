import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/diary_streak/diary_streak.dart';
import '../../../blocs/food_count_by_irritant/food_count_by_irritant.dart';
import '../../../blocs/recent_severity/recent_severity.dart';
import '../../../blocs/symptom_type_count/symptom_type_count.dart';
import 'diary_streak_section.dart';
import 'food_count_by_irritant_section.dart';
import 'recent_severity_section.dart';
import 'symptom_type_section.dart';

class AnalysisListView extends StatelessWidget {
  const AnalysisListView({Key? key}) : super(key: key);

  /// Build a AnalysisListView with its own Bloc providers.
  static Widget provisioned() {
    final symptomTypeCountSince = DateTime.now().subtract(SymptomTypeCountSection.duration);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DiaryStreakCubit.fromContext(context, dateCount: DiaryStreakSection.daysShown),
        ),
        const BlocProvider(create: FoodCountByIrritantCubit.fromContext),
        BlocProvider(
          create: (context) => RecentSeverityCubit.fromContext(context, dateCount: RecentSeveritySection.dateCount),
        ),
        BlocProvider(
          create: (context) => SymptomTypeCountCubit.fromContext(context, countSince: symptomTypeCountSince),
        ),
      ],
      child: const AnalysisListView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DiaryStreakSection.provisioned(),
        FoodCountByIrritantSection.provisioned(),
        RecentSeveritySection.provisioned(),
        SymptomTypeCountSection.provisioned(),
      ],
    );
  }
}
