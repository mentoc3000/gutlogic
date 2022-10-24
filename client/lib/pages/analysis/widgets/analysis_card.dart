import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/subscription/subscription.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
import '../../../widgets/cards/headed_card.dart';

class AnalysisCard extends StatelessWidget {
  final String heading;
  final Widget subscribedContent;
  final Widget exampleContent;

  const AnalysisCard({
    Key? key,
    required this.heading,
    required this.subscribedContent,
    required this.exampleContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blurSigma = 2.0;

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      late final Widget content;

      if (state is Subscribed) {
        content = subscribedContent;
      } else {
        content = Stack(children: [
          exampleContent,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: GLColors.white.withOpacity(0.8),
                  child: Center(
                    child: GLCtaButton(
                      onPressed: () => Navigator.of(context).push(Routes.of(context).createSubscribeRoute()),
                      child: const ShrinkWrappedButtonContent(label: 'Subscribe to unlock'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]);
      }

      return HeadedCard(
        heading: heading,
        content: content,
      );
    });
  }
}
