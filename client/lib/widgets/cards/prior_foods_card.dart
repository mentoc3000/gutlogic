import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/subscription/subscription.dart';
import '../../routes/routes.dart';
import '../../style/gl_color_scheme.dart';
import '../../style/gl_text_style.dart';
import '../gl_icons.dart';
import 'push_card.dart';

class PriorFoodsCard extends StatelessWidget {
  final DateTime dateTime;

  const PriorFoodsCard({Key? key, required this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(builder: (BuildContext context, SubscriptionState state) {
      late final void Function()? onTap;
      final children = <Widget>[
        Row(
          children: const [
            Icon(GLIcons.priorFoods),
            SizedBox(width: 8),
            Text('Prior foods eaten', style: tileSubheadingStyle),
          ],
        )
      ];

      if (state is Subscribed) {
        onTap = () => Navigator.of(context).push(Routes.of(context).createPriorFoodsPageRoute(dateTime: dateTime));
      } else {
        onTap = () => Navigator.of(context).push(Routes.of(context).subscribe);
        children.addAll([
          const SizedBox(height: 4.0),
          Row(
            children: [
              const SizedBox(width: 32),
              Text(
                'Subscribe to unlock',
                // TODO: update color to orange or purple
                style: TextStyle(color: glColorScheme.secondary),
              ),
            ],
          )
        ]);
      }

      return PushCard(
        onTap: onTap,
        child: Column(children: children),
      );
    });
  }
}
