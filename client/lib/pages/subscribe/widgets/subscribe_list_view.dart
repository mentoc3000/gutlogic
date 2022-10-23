import 'package:flutter/material.dart';

import '../../../widgets/page_column.dart';
import 'feature_list.dart';
import 'feature_summary.dart';
import 'purchase_interface.dart';
import 'subscribe_title.dart';

class SubscribeListView extends StatelessWidget {
  const SubscribeListView();

  @override
  Widget build(BuildContext context) {
    return ConstrainedScrollView(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 20.0),
        child: Column(
          children: const [
            Expanded(child: PremiumLogo()),
            FeatureSummary(),
            FeatureList(),
            PurchaseInterface(),
          ],
        ),
      ),
    );
  }
}
