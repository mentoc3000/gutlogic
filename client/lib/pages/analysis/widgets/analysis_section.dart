import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/subscription/subscription.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';
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
    const blurSigma = 2.0;
    const opacity = 0.6;

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
                  color: GLColors.white.withOpacity(opacity),
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

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            HeaderListTile(heading: heading),
            content,
          ],
        ),
      );
    });
  }
}
