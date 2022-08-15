import 'package:flutter/material.dart';

import 'diary_streak_card.dart';
import 'food_count_by_irritant_card.dart';
import 'recent_severity_card.dart';
import 'symptom_type_count.dart';

class AnalysisListView extends StatelessWidget {
  const AnalysisListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = [
      DiaryStreakCard.provisioned(),
      FoodCountByIrritantCard.provisioned(),
      RecentSeverityCard.provisioned(),
      SymptomTypeCountCard.provisioned(),
    ];

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(padding: const EdgeInsets.all(1.0), child: cards[index]);
      },
    );
  }
}
