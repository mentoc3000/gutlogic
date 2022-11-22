import 'package:flutter/material.dart';

import '../../../widgets/page_column.dart';
import 'feature_list.dart';
import 'feature_summary.dart';
import 'legal_links.dart';
import 'purchase_interface.dart';
import 'subscribe_title.dart';

class SubscribeListView extends StatelessWidget {
  final VoidCallback? onSubscribed;

  const SubscribeListView({required this.onSubscribed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScrollView(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 20.0),
        child: Column(
          children: [
            const Expanded(child: PremiumLogo()),
            const FeatureSummary(),
            const FeatureList(),
            PurchaseInterface(onSubscribed: onSubscribed),
            const LegalLinks(),
          ],
        ),
      ),
    );
  }
}
