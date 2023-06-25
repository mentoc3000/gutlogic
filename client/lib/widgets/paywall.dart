import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/subscription/subscription.dart';
import '../../../routes/routes.dart';
import '../../../style/gl_colors.dart';
import '../../../widgets/buttons/buttons.dart';

class Paywall extends StatelessWidget {
  final Widget child;
  final Widget? exampleChild;
  final Color color;

  const Paywall({Key? key, required this.child, this.exampleChild, this.color = GLColors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blurSigma = 2.0;
    const opacity = 0.6;

    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      if (state is Subscribed) {
        return child;
      } else {
        return Stack(children: [
          exampleChild ?? child,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: color.withOpacity(opacity),
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
    });
  }
}
