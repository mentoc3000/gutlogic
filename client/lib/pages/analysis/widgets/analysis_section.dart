import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gutlogic/widgets/paywall.dart';

import '../../../blocs/subscription/subscription.dart';
import '../../../widgets/list_tiles/header_list_tile.dart';

class AnalysisSection extends StatelessWidget {
  final String heading;
  final Widget subscribedContent;
  final Widget exampleContent;

  const AnalysisSection({
    Key? key,
    required this.heading,
    required this.subscribedContent,
    required this.exampleContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            HeaderListTile(heading: heading),
            Paywall(exampleChild: exampleContent, child: subscribedContent),
          ],
        ),
      );
    });
  }
}
