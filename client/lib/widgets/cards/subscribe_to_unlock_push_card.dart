import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../routes/routes.dart';
import '../../style/gl_colors.dart';
import '../../style/gl_text_style.dart';
import 'push_card.dart';

class SubscribeToUnlockPushCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? trailing;
  final void Function() onTapSubscribed;

  const SubscribeToUnlockPushCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTapSubscribed,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      late final void Function()? onTap;
      const style = tileSubheadingStyle;
      final children = <Widget>[
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(text, style: style),
          ],
        )
      ];

      if (state is Subscribed) {
        onTap = onTapSubscribed;
      } else {
        onTap =
            () => Navigator.of(context).push(Routes.of(context).createSubscribeRoute(onSubscribed: onTapSubscribed));
        children.addAll([
          const SizedBox(height: 4.0),
          Row(
            children: const [
              SizedBox(width: 32),
              Text('Subscribe to unlock', style: TextStyle(color: GLColors.darkGold)),
            ],
          )
        ]);
      }

      return PushCard(
        onTap: onTap,
        child: Expanded(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
              const Spacer(),
              if (trailing != null) trailing!
            ],
          ),
        ),
      );
    });
  }
}
